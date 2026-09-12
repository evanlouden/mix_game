class RenameStartingCardsToStartingCardsDown < ActiveRecord::Migration[8.1]
  def up
    rename_column :variants, :starting_cards, :starting_cards_down if column_exists?(:variants, :starting_cards)
    change_column :variants, :starting_cards_down, :integer, using: "NULLIF(regexp_replace(starting_cards_down, '[^0-9].*$', ''), '')::integer" if column_exists?(:variants, :starting_cards_down)
  end

  def down
    change_column :variants, :starting_cards_down, :text if column_exists?(:variants, :starting_cards_down)
    rename_column :variants, :starting_cards_down, :starting_cards if column_exists?(:variants, :starting_cards_down)
  end
end
