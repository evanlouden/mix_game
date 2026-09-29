class CompleteSevenCardFlip8Sequence < ActiveRecord::Migration[8.1]
  def up
    SequenceStep.where(variant_id: 211, position: 2..9).delete_all

    SequenceStep.where(variant_id: 210, position: 2..9).order(:position).each do |step|
      SequenceStep.create!(
        variant_id: 211,
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
    SequenceStep.where(variant_id: 211, position: 2..9).delete_all
    SequenceStep.create!(variant_id: 211, position: 2, action_type: "betting")
  end
end
