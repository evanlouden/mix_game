class RestoreA5SingleDraw < ActiveRecord::Migration[8.1]
  def up
    return if Variant.exists?(source_id: "V001")

    workbook = JSON.parse(Rails.root.join("db/data/workbook.json").read)
    index = workbook.fetch("model").index { |entry| entry["variant_id"] == "V001" }
    row = workbook.fetch("variants").fetch(index)
    attributes = Variant::FIELDS.to_h { |field, column| [field, row[column].presence] }
    attributes[:starting_cards_down] = row["Starting Cards"].presence
    attributes[:starting_cards_up] = row["Initial Up Cards"].presence
    attributes[:betting_format] = "fixed_limt"
    attributes[:wild_cards] = nil
    attributes[:special_mechanics] = row["Special Mechanics"].to_s.gsub(/\bBug\s*is\s*wild\.?/i, "").gsub(/\s+/, " ").strip.presence
    detail = %w[sequence hand_rules tags].to_h { |sheet| [sheet, workbook.fetch(sheet).select { |entry| entry["variant_id"] == "V001" }] }
    detail["model"] = workbook.fetch("model").fetch(index)
    detail["raw_pages"] = workbook.fetch("raw_pages").select { |page| page["Variant"] == row["Variant"] && page["Game Type"] == row["Game Type"] }
    detail["source"] = workbook.fetch("sources").fetch(index)
    variant = Variant.create!(attributes.merge(source_id: "V001", source_detail: detail))
    detail.fetch("sequence", []).reject { |event| event["event_name"].to_s.casecmp("Special mechanic").zero? }.each_with_index do |event, position|
      community = event["community_card_count"].to_i
      hole = event["hole_card_count"].to_i
      type = event["event_type"].to_s.downcase
      variant.sequence_steps.create!(position: position + 1, action_type: SequenceStep::TYPES.include?(type) ? type : "special", card_scope: community.positive? ? "community" : hole.positive? ? "individual" : nil, cards_down: hole.positive? ? hole : nil, cards_up: community.positive? ? community : nil, max_cards: type == "draw" ? 5 : nil)
    end
    variant.hand_rules.create!(pot_number: 1, rule: "ace_to_five_low", ace_behavior: "low", hand_size: 5, notes: "A–5 Single Draw hand")
  end

  def down
    Variant.where(source_id: "V001").destroy_all
  end
end
