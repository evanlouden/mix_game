class CreateHandRules < ActiveRecord::Migration[8.1]
  def change
    create_table :hand_rules do |t|
      t.references :variant, null: false, foreign_key: true
      t.integer :pot_number, null: false, default: 1
      t.string :direction
      t.string :hand_type
      t.integer :hand_size, default: 5
      t.integer :hole_cards_required
      t.integer :community_cards_required
      t.string :rule, null: false, default: "standard_high"
      t.string :qualifier
      t.text :notes
      t.string :source_pages
      t.timestamps
    end
    add_index :hand_rules, %i[variant_id pot_number]
  end
end
