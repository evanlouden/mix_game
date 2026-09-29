class RemoveLegacyVariantAttributes < ActiveRecord::Migration[8.1]
  LEGACY_COLUMNS = %i[
    source_id betting_structure starting_cards_down starting_cards_up qualifier high_hand low_hand
    final_hand wild_cards deck_modification action_order best_hand source_pages source_notes
    source_detail betting_format
  ].freeze

  def change
    remove_index :variants, :source_id, if_exists: true
    LEGACY_COLUMNS.each { |column| remove_column :variants, column, if_exists: true }
  end
end
