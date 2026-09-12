class CreateVariants < ActiveRecord::Migration[8.1]
  def change
    create_table :variants do |t|
      t.string :source_id
      t.string :name, null: false
      t.string :game_type, null: false
      t.string :family, null: false
      %i[max_players forced_bet bring_in raise_to_open betting_structure betting_rounds
         starting_cards initial_up_cards community_board draw_count draw_details discard_details
         split_pot qualifier high_hand low_hand final_hand wild_cards deck_modification
         action_order special_mechanics best_hand source_pages source_notes].each { |field| t.text field }
      t.jsonb :source_detail, default: {}, null: false
      t.timestamps
    end
    add_index :variants, :source_id, unique: true
    add_index :variants, :family
    add_index :variants, :game_type
  end
end
