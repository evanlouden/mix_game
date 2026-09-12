Variant.where(max_players: [nil, ""]).find_each do |variant|
  text = [variant.special_mechanics, variant.source_notes, variant.final_hand].compact.join(" ")
  matches = text.scan(/\d+\s+Players?\s+Max/i)
  puts [variant.source_id, variant.name, matches].inspect if matches.any?
end
