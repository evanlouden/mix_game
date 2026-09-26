class AddMissingInitialDealSteps < ActiveRecord::Migration[8.1]
  def up
    Variant.find_each do |variant|
      next if variant.sequence_steps.where(action_type: %w[deal community]).exists?

      down = variant.starting_cards_down.to_i
      up = variant.starting_cards_up.to_i
      next unless down.positive? || up.positive?

      variant.sequence_steps.update_all("position = position + 1")
      variant.sequence_steps.create!(
        position: 1,
        action_type: "deal",
        card_scope: "individual",
        number_of_cards: down + up,
        cards_down: down.positive? ? down : nil,
        cards_up: up.positive? ? up : nil,
        quantity_unit: down.positive? ? "cards" : nil
      )
    end
  end

  def down
    # Missing initial deals are retained on rollback.
  end
end
