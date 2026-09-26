class RemoveQuantityUnitAndNumberOfCards < ActiveRecord::Migration[8.1]
  def up
    add_column :sequence_steps, :cards_up, :integer unless column_exists?(:sequence_steps, :cards_up)
    execute "UPDATE sequence_steps SET cards_up = number_of_cards WHERE card_scope = 'community' AND number_of_cards IS NOT NULL AND cards_up IS NULL"
    remove_column :sequence_steps, :quantity_unit
    remove_column :sequence_steps, :number_of_cards
  end

  def down
    add_column :sequence_steps, :number_of_cards, :integer
    add_column :sequence_steps, :quantity_unit, :string
  end
end
