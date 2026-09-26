class AddCardScopeToSequenceSteps < ActiveRecord::Migration[8.1]
  def up
    add_column :sequence_steps, :card_scope, :string
    execute "UPDATE sequence_steps SET card_scope = 'community' WHERE quantity_unit = 'community cards' OR action_type = 'community'"
    execute "UPDATE sequence_steps SET card_scope = 'individual' WHERE card_scope IS NULL AND (cards_down IS NOT NULL OR cards_up IS NOT NULL OR quantity_unit = 'cards')"
  end

  def down
    remove_column :sequence_steps, :card_scope
  end
end
