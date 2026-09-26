class AddMaxCardsToSequenceSteps < ActiveRecord::Migration[8.1]
  def up
    add_column :sequence_steps, :max_cards, :integer
    execute <<~SQL
      UPDATE sequence_steps
      SET max_cards = CASE
        WHEN variants.name ILIKE '%Badugi%' THEN 4
        WHEN variants.name ILIKE '%Dramaha%' THEN 2
        ELSE 5
      END
      FROM variants
      WHERE variants.id = sequence_steps.variant_id
        AND sequence_steps.action_type IN ('draw', 'discard')
    SQL
  end

  def down
    remove_column :sequence_steps, :max_cards
  end
end
