class DuplicateActionRazzHard < ActiveRecord::Migration[8.1]
  def up
    source = Variant.find(225)
    duplicate = source.dup
    duplicate.name = "Action Razz - Hard"
    duplicate.source_id = nil
    duplicate.save!

    source.sequence_steps.each do |step|
      duplicate.sequence_steps.create!(
        position: step.position,
        action_type: step.action_type,
        max_cards: step.max_cards,
        cards_down: step.cards_down,
        cards_up: step.cards_up,
        card_scope: step.card_scope,
        number_of_boards: step.number_of_boards,
        min_cards: step.min_cards
      )
    end
  end

  def down
    variant = Variant.find_by(name: "Action Razz - Hard")
    variant&.destroy!
  end
end
