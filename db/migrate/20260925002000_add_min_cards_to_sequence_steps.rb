class AddMinCardsToSequenceSteps < ActiveRecord::Migration[8.1]
  def up
    add_column :sequence_steps, :min_cards, :integer

    execute <<~SQL
      UPDATE sequence_steps
      SET min_cards = 0
      WHERE action_type = 'draw'
    SQL

    execute <<~SQL
      UPDATE sequence_steps
      SET min_cards = CASE
        WHEN variants.name ILIKE 'Scrotum%' THEN 0
        ELSE 1
      END,
      max_cards = CASE
        WHEN variants.name ILIKE 'Scrotum%' THEN 5
        ELSE 1
      END
      FROM variants
      WHERE variants.id = sequence_steps.variant_id
        AND sequence_steps.action_type = 'discard'
    SQL
  end

  def down
    remove_column :sequence_steps, :min_cards
  end
end
