class RenameInitialUpCardsToStartingCardsUp < ActiveRecord::Migration[8.1]
  def up
    rename_column :variants, :initial_up_cards, :starting_cards_up if column_exists?(:variants, :initial_up_cards)
    change_column :variants, :starting_cards_up, :integer, using: "NULLIF(regexp_replace(starting_cards_up, '[^0-9].*$', ''), '')::integer" if column_exists?(:variants, :starting_cards_up)
  end

  def down
    change_column :variants, :starting_cards_up, :text if column_exists?(:variants, :starting_cards_up)
    rename_column :variants, :starting_cards_up, :initial_up_cards if column_exists?(:variants, :starting_cards_up)
  end
end
