class CompleteUpsideDownPineapple8Sequence < ActiveRecord::Migration[8.1]
  def up
    SequenceStep.where(variant_id: 132).where(position: 3..10).order(:position).each do |step|
      SequenceStep.create!(
        variant_id: 133,
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
    SequenceStep.where(variant_id: 133, position: 3..10).delete_all
  end
end
