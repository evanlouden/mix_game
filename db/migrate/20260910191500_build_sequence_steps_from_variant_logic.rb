class BuildSequenceStepsFromVariantLogic < ActiveRecord::Migration[8.1]
  def up
    Variant.find_each do |variant|
      variant.sequence_steps.delete_all
      events_for(variant).each_with_index do |event, index|
        create_step(variant, event, index + 1)
      end
    end
  end

  def down
    # Sequence steps are retained on rollback.
  end

  private

  def events_for(variant)
    name = variant.name.to_s
    if name == "6-Card Shodugi"
      ["6 DOWN", "SEPARATE 2 & 4 · CAP", "BET", "FLOP 3", "BET", "BADUGI DRAW", "2 COMMUNITY", "BET", "RIVER", "BET"].map { |label| { "event_name" => label } }
    elsif name.match?(/Dra.*maha/i)
      ["5 DOWN", "BET", "C C C", "BET", "DRAW", "C", "BET", "C", "BET"].map { |label| { "event_name" => label } }
    elsif name.match?(/\ACrazy Pineapple(?: 8)?\z/i)
      ["3 DOWN", "BET", "C C C", "BET", "DISCARD 1 CARD", "C", "BET", "C", "BET"].map { |label| { "event_name" => label } }
    elsif name.match?(/\APineapple(?: 8)?\z/i)
      ["3 DOWN", "DISCARD 1 CARD", "BET", "C C C", "BET", "C", "BET", "C", "BET"].map { |label| { "event_name" => label } }
    elsif variant.family.to_s == "Stud"
      initial = variant.source_detail.to_h.fetch("sequence", []).first.to_h
      if initial["hole_card_count"].to_i == 2 && initial["up_card_count"].to_i == 1
        ["2 DOWN + 1 UP", "BET", "1 UP", "BET", "1 UP", "BET", "1 UP", "BET", "1 DOWN", "BET"].map { |label| { "event_name" => label } }
      elsif initial["hole_card_count"].to_i == 1 && initial["up_card_count"].to_i == 1
        ["1 DOWN + 1 UP", "BET", "1 UP", "BET", "1 UP", "BET"].map { |label| { "event_name" => label } }
      else
        source_events(variant)
      end
    else
      source_events(variant)
    end
  end

  def source_events(variant)
    variant.source_detail.to_h.fetch("sequence", []).reject do |event|
      event["event_name"].to_s.casecmp("Special mechanic").zero?
    end
  end

  def create_step(variant, event, position)
    raw_type = event["event_type"].to_s.downcase
    label = event["event_name"].presence || raw_type.humanize
    text = label.to_s.upcase
    community = event["community_card_count"].to_i
    hole = event["hole_card_count"].to_i

    if text == "BET"
      type = "betting"
      label = "Bet"
    elsif text.match?(/\A(?:C\s*)+\z/)
      type = "deal"
      community = text.scan("C").length
      label = "Community"
    elsif text.match?(/\A(?:FLOP|\d+ COMMUNITY)/)
      type = "deal"
      community = text[/\d+/].to_i
      label = "Community"
    elsif text.match?(/\A\d+ DOWN/) || raw_type == "deal"
      type = "deal"
      hole = text[/\d+/].to_i if hole.zero?
    elsif text.start_with?("DRAW")
      type = "draw"
    elsif text.start_with?("DISCARD")
      type = "discard"
    else
      type = SequenceStep::TYPES.include?(raw_type) ? raw_type : "special"
    end

    max_cards = if %w[draw discard].include?(type)
      variant.name.to_s.match?(/Badugi/i) ? 4 : variant.name.to_s.match?(/Dramaha/i) ? 2 : 5
    end
    quantity = community.positive? ? community : hole.positive? ? hole : nil
    unit = community.positive? ? "community cards" : hole.positive? ? "cards" : nil
    variant.sequence_steps.create!(position: position, action_type: type, number_of_cards: quantity, max_cards: max_cards, quantity_unit: unit)
  end
end
