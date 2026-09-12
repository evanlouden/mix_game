workbook = JSON.parse(Rails.root.join("db/data/workbook.json").read)
workbook.fetch("hand_rules").group_by { |entry| entry["variant_id"] }.each do |source_id, entries|
  variant = Variant.find_by(source_id: source_id)
  next unless variant

  entries.each do |entry|
    direction = variant.name.match?(/Dra.*maha/i) ? nil : entry["pot_name"].to_s.match?(/low/i) ? "low" : entry["pot_name"].to_s.match?(/high/i) ? "high" : nil
    rule = variant.hand_rules.find_by(pot_number: entry["pot_number"].to_i)
    if rule && variant.family == "Omaha" && rule.hole_cards_required.blank? && entry["hand_construction_or_ranking"].to_s.match?(/High hand|Lowest/i)
      rule.update!(hole_cards_required: 2, community_cards_required: 3)
    end
    rule&.update!(direction: direction)
    if rule
      notes = entry["hand_construction_or_ranking"].to_s
      ace_behavior = if notes.match?(/Ace is (?:always )?high/i) then "high" elsif notes.match?(/Ace is (?:always )?low/i) then "low" elsif notes.match?(/Ace/i) then "either" else { "ace_to_five_low" => "low", "deuce_to_seven_low" => "high", "badugi" => "low", "badeucey" => "high" }.fetch(rule.rule, nil) end
      rule.update!(ace_behavior: ace_behavior) if ace_behavior
    end
    if rule && variant.name.match?(/Dra.*maha/i) && entry["hand_construction_or_ranking"].to_s.match?(/Omaha hand/i)
      rule.update!(rule: "standard_high", hole_cards_required: 2, community_cards_required: 3)
    end
  end
end
puts "Updated hand-rule directions."
