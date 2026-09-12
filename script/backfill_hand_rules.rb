workbook = JSON.parse(Rails.root.join("db/data/workbook.json").read)
workbook.fetch("hand_rules").group_by { |entry| entry["variant_id"] }.each do |source_id, entries|
  variant = Variant.find_by(source_id: source_id)
  next unless variant && !variant.hand_rules.exists?

  entries.each do |entry|
    construction = entry["hand_construction_or_ranking"].to_s
    hole = construction.match(/(?:using|from)\s+(?:exactly\s+)?(\d+)\s+(?:Individual|down)/i)&.[](1)
    community = construction.match(/(\d+)\s+(?:Community|community)/)&.[](1)
    if variant.family == "Omaha" && hole.blank? && community.blank? && construction.match?(/High hand|Lowest/i)
      hole = "2"
      community = "3"
    end
    rule = if construction.match?(/pip\s*count/i) && construction.match?(/high/i) then "pip_count_high" elsif construction.match?(/pip\s*count/i) && construction.match?(/low/i) then "pip_count_low" elsif construction.match?(/2[–-]7|Deuce\s+to\s+Seven/i) then "deuce_to_seven_low" elsif variant.name.match?(/Badeucey/i) && construction.match?(/Badugi|Ace is high/i) then "badeucey" elsif construction.match?(/Badugi/i) then "badugi" elsif construction.match?(/Lowest|Razz|A[–-]5|Ace is low|lowball/i) then "ace_to_five_low" else "standard_high" end
    variant.hand_rules.create!(pot_number: entry["pot_number"].to_i, hand_size: 5, hole_cards_required: hole, community_cards_required: community, rule: rule, qualifier: entry["qualifier"].presence, notes: construction, source_pages: entry["source_pages"])
  end
end
puts "Backfilled #{HandRule.count} hand rules."
