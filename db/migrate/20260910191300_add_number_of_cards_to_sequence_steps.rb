class AddNumberOfCardsToSequenceSteps < ActiveRecord::Migration[8.1]
  def up
    add_column :sequence_steps, :number_of_cards, :integer
    execute "UPDATE sequence_steps SET number_of_cards = quantity WHERE quantity IS NOT NULL"
    execute "UPDATE sequence_steps SET action_type = 'deal', label = 'Community' WHERE action_type = 'deal' AND quantity_unit = 'community cards'"
  end

  def down
    remove_column :sequence_steps, :number_of_cards
  end
end
