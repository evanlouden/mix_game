workbook = JSON.parse(Rails.root.join("db/data/workbook.json").read)
Variant.transaction do
  workbook.fetch("variants").each_with_index do |row, index|
    next if row.values.any? { |value| value.to_s.match?(/Bug is wild/i) }
    source_id = workbook.fetch("model").fetch(index).fetch("variant_id")
    existing_variant = Variant.find_by(source_id: source_id)
    next if existing_variant&.sequence_steps&.exists?

    attributes = Variant::FIELDS.to_h { |field, column| [ field, row.fetch(column, nil).presence ] }
    attributes[:starting_cards_down] = row["Starting Cards"].presence
    attributes[:starting_cards_up] = row["Initial Up Cards"].presence
    attributes[:betting_format] = if row["Betting Limit / Category"].to_s.match?(/Fixed-Limit/i)
      "fixed_limt"
    elsif row["Betting Limit / Category"].to_s.match?(/Pot-Limit/i)
      "pot_limit"
    else
      "no_limit"
    end
    if attributes[:max_players].blank?
      match = attributes[:special_mechanics].to_s.match(/(\d+)\s+Players?\s+Max/i)
      attributes[:max_players] = match[1] if match
    end
    detail = %w[sequence hand_rules tags].to_h do |sheet|
      [ sheet, workbook.fetch(sheet).select { |entry| entry["variant_id"] == source_id } ]
    end
    detail["raw_pages"] = workbook.fetch("raw_pages").select do |entry|
      entry["Variant"] == row["Variant"] && entry["Game Type"] == row["Game Type"] && entry["Family"] == row["Family"]
    end
    if attributes[:max_players].blank?
      raw_text = detail["raw_pages"].filter_map { |page| page["Raw Page Text"] }.join(" ")
      match = raw_text.match(/(\d+)\s+Players?\s+Max/i)
      attributes[:max_players] = match[1] if match
    end
    detail["model"] = workbook.fetch("model").fetch(index)
    if row["Variant"] == "6-Card Shodugi" && detail["sequence"].none? { |event| event["community_card_count"].to_i == 3 }
      detail["sequence"] = [{ "event_type" => "deal", "hole_card_count" => "6" }, { "event_type" => "special", "event_name" => "Separate" }, { "event_type" => "special", "event_name" => "Cap" }, { "event_type" => "betting" }, { "event_type" => "deal", "community_card_count" => "3" }, { "event_type" => "betting" }, { "event_type" => "draw", "event_name" => "Badugi draw" }, { "event_type" => "deal", "community_card_count" => "2" }, { "event_type" => "betting" }, { "event_type" => "deal", "event_name" => "River", "community_card_count" => "1" }, { "event_type" => "betting" }]
    end
    detail["source"] = workbook.fetch("sources").fetch(index)
    variant = existing_variant || Variant.create!(attributes.merge(source_id: source_id, source_detail: detail))
    if row["Variant"] == "Archie"
      variant.update_columns(special_mechanics: "High qualifier: 99 or better (CAZ) or 66 or better (LV variant).")
    elsif row["Variant"] == "Gardena Jackpots"
      variant.update_columns(special_mechanics: "Jacks or better to open; trips to win.")
    elsif row["Variant"] == "Jacks Back"
      variant.update_columns(special_mechanics: "Jacks or better to open; otherwise California Lowball (A-5).")
    end
    sequence = detail.fetch("sequence", [])
    if row["Variant"] == "6-Card Shodugi"
      labels = ["6 down", "Separate 2 & 4 · Cap", "Bet", "Flop", "Bet", "Badugi draw", "Community", "Bet", "River", "Bet"]
      card_counts = [6, nil, nil, 3, nil, nil, 2, nil, 1, nil]
      labels.each_with_index do |label, position|
        type = label.start_with?("Bet") ? "betting" : label == "Flop" || label == "Community" ? "deal" : "special"
        unit = label == "Flop" || label == "Community" ? "community cards" : nil
        variant.sequence_steps.create!(position: position + 1, action_type: type, card_scope: unit == "community cards" ? "community" : nil, cards_up: unit == "community cards" ? card_counts[position] : nil)
      end
    else
      sequence.each_with_index do |event, position|
        next if event["event_name"].to_s.casecmp("Special mechanic").zero?
        type = event["event_type"].to_s.downcase
        community_cards = event["community_card_count"].to_i
        hole_cards = event["hole_card_count"].to_i
        type = "deal" if type == "deal" && community_cards.positive?
        label = if type == "deal" && community_cards.positive?
          "Community"
        elsif type == "deal" && hole_cards.positive?
          "#{hole_cards} cards"
        elsif type == "betting"
          "Bet"
        elsif type == "draw" || type == "special"
          event["event_name"].presence || type.humanize
        else
          event["event_name"].presence || type.humanize
        end
        min_cards = if type == "draw"
          0
        elsif type == "discard"
          row["Variant"].to_s.match?(/\AScrotum(?: 8)?\z/i) ? 0 : 1
        end
        max_cards = if type == "draw"
          row["Variant"].to_s.match?(/Badugi/i) ? 4 : row["Variant"].to_s.match?(/Dramaha/i) ? 2 : 5
        elsif type == "discard"
          row["Variant"].to_s.match?(/\AScrotum(?: 8)?\z/i) ? 5 : 1
        end
        variant.sequence_steps.create!(position: position + 1, action_type: SequenceStep::TYPES.include?(type) ? type : "special", card_scope: community_cards.positive? ? "community" : hole_cards.positive? || event["up_card_count"].to_i.positive? ? "individual" : nil, cards_down: hole_cards.positive? ? hole_cards : nil, cards_up: community_cards.positive? ? community_cards : event["up_card_count"].to_i.positive? ? event["up_card_count"].to_i : nil, min_cards: min_cards, max_cards: max_cards)
      end
    end
    workbook.fetch("hand_rules").select { |entry| entry["variant_id"] == source_id }.each do |entry|
      construction = entry["hand_construction_or_ranking"].to_s
      hole = construction.match(/(?:using|from)\s+(?:exactly\s+)?(\d+)\s+(?:Individual|down)/i)&.[](1)
      community = construction.match(/(\d+)\s+(?:Community|community)/)&.[](1)
      if row["Family"] == "Omaha" && hole.blank? && community.blank? && construction.match?(/High hand|Lowest/i)
        hole = "2"
        community = "3"
      end
      if row["Variant"].match?(/Dra.*maha/i) && construction.match?(/Omaha hand/i)
        hole = "2"
        community = "3"
        rule = "standard_high"
      end
      rule = if construction.match?(/pip\s*count/i) && construction.match?(/high/i)
        "pip_count_high"
      elsif construction.match?(/pip\s*count/i) && construction.match?(/low/i)
        "pip_count_low"
      elsif construction.match?(/2[–-]7|Deuce\s+to\s+Seven/i)
        "deuce_to_seven_low"
      elsif row["Variant"].match?(/Badeucey/i) && construction.match?(/Badugi|Ace is high/i)
        "badeucey"
      elsif construction.match?(/Badugi/i)
        "badugi"
      elsif construction.match?(/2[–-]7/i)
        "deuce_to_seven_low"
      elsif construction.match?(/Lowest|Razz|A[–-]5|Ace is low|lowball/i)
        "ace_to_five_low"
      else
        "standard_high"
      end
      direction = row["Variant"].match?(/Dra.*maha/i) ? nil : entry["pot_name"].to_s.match?(/low/i) ? "low" : entry["pot_name"].to_s.match?(/high/i) ? "high" : nil
      ace_behavior = if construction.match?(/Ace is (?:always )?high/i)
        "high"
      elsif construction.match?(/Ace is (?:always )?low/i)
        "low"
      elsif construction.match?(/Ace/i)
        "either"
      else
        { "ace_to_five_low" => "low", "deuce_to_seven_low" => "high", "badugi" => "low", "badeucey" => "high" }.fetch(rule, "either")
      end
      variant.hand_rules.create!(pot_number: entry["pot_number"].to_i, direction: direction, ace_behavior: ace_behavior, hand_size: 5, hole_cards_required: hole, community_cards_required: community, rule: rule, qualifier: entry["qualifier"].presence, notes: construction, source_pages: entry["source_pages"])
    end
    variant.update_columns(pot_1_hand_rule: variant.hand_rules.find_by(pot_number: 1)&.notes, pot_2_hand_rule: variant.hand_rules.find_by(pot_number: 2)&.notes)
  end
end
puts "#{Variant.count} poker variants available. Existing records were left intact."
