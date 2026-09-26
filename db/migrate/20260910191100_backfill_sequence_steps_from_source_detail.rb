class BackfillSequenceStepsFromSourceDetail < ActiveRecord::Migration[8.1]
  def up
    Variant.find_each do |variant|
      next if variant.sequence_steps.exists?

      sequence = variant.source_detail.to_h.fetch("sequence", [])
      sequence.each_with_index do |event, index|
        type = event["event_type"].to_s.downcase
        next if event["event_name"].to_s.casecmp("Special mechanic").zero?

        community = event["community_card_count"].to_i
        hole = event["hole_card_count"].to_i
        label = if type == "deal" && community.positive?
          "#{community} community cards"
        elsif type == "deal" && hole.positive?
          "#{hole} cards"
        elsif type == "betting"
          "Bet"
        else
          event["event_name"].presence || type.humanize
        end
        type = "deal" if type == "deal" && community.positive?
        label = "Community" if type == "deal" && community.positive?
        action_type = SequenceStep::TYPES.include?(type) ? type : "special"
        variant.sequence_steps.create!(position: index + 1, action_type: action_type, number_of_cards: community.positive? ? community : hole.positive? ? hole : nil, quantity_unit: community.positive? ? "community cards" : hole.positive? ? "cards" : nil)
      end
    end
  end

  def down
    # Existing sequence steps are retained on rollback.
  end
end
