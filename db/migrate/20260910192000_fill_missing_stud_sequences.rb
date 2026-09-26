class FillMissingStudSequences < ActiveRecord::Migration[8.1]
  def up
    Variant.where(family: "Stud").find_each do |variant|
      next if variant.sequence_steps.where(action_type: %w[deal community]).exists?

      down = variant.starting_cards_down.to_i
      up = variant.starting_cards_up.to_i
      if down.zero? && up.zero? && variant.name.to_s.match?(/2.?7 Razz/i)
        down = 2
        up = 1
      end
      next unless down.positive? || up.positive?

      variant.sequence_steps.delete_all
      steps = [{ action_type: "deal", cards_down: down.positive? ? down : nil, cards_up: up.positive? ? up : nil }]
      steps << { action_type: "betting" }

      five_card = variant.name.to_s.match?(/5.?Card Stud/i)
      remaining = five_card ? 3 : [7 - (down + up) - 1, 0].max
      remaining.times do
        steps << { action_type: "deal", cards_up: 1 }
        steps << { action_type: "betting" }
      end
      if !five_card && down + up + remaining < 7
        steps << { action_type: "deal", cards_down: 1 }
        steps << { action_type: "betting" }
      end

      steps.each_with_index do |attrs, index|
        cards_down = attrs[:cards_down]
        cards_up = attrs[:cards_up]
        step_attrs = attrs.merge(
          position: index + 1,
          card_scope: attrs[:action_type] == "deal" ? "individual" : nil,
          number_of_cards: cards_down.to_i + cards_up.to_i,
          quantity_unit: cards_down ? "cards" : nil
        )
        step_attrs[:number_of_cards] = nil unless cards_down || cards_up
        variant.sequence_steps.create!(step_attrs)
      end
    end
  end

  def down
    # Generated Stud sequences are retained on rollback.
  end
end
