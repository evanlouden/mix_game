class CreateCurrentSchema < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.datetime :created_at, null: false
      t.string :email, default: "", null: false
      t.string :encrypted_password, default: "", null: false
      t.datetime :remember_created_at
      t.datetime :reset_password_sent_at
      t.string :reset_password_token
      t.datetime :updated_at, null: false
    end

    add_index :users, :email, unique: true
    add_index :users, :reset_password_token, unique: true

    create_table :variants do |t|
      t.column :bomb_pot, "BOOLEAN", default: false, null: false
      t.text :bring_in
      t.datetime :created_at, null: false
      t.string :family, null: false
      t.column :fixed_limit, "BOOLEAN", default: false, null: false
      t.text :forced_bet
      t.text :max_players
      t.string :name, null: false
      t.column :no_limit, "BOOLEAN", default: false, null: false
      t.text :pot_1_hand_rule
      t.string :pot_1_qualifier
      t.text :pot_2_hand_rule
      t.string :pot_2_qualifier
      t.column :pot_limit, "BOOLEAN", default: false, null: false
      t.text :special_mechanics
      t.datetime :updated_at, null: false
    end

    add_index :variants, :family

    create_table :sequence_steps do |t|
      t.string :action_type, null: false
      t.string :card_scope
      t.integer :cards_down
      t.integer :cards_up
      t.datetime :created_at, null: false
      t.integer :max_cards
      t.integer :min_cards
      t.integer :number_of_boards
      t.integer :position, null: false
      t.datetime :updated_at, null: false
      t.bigint :variant_id, null: false
    end

    add_index :sequence_steps, :action_type
    add_index :sequence_steps, :variant_id
    add_index :sequence_steps, %i[variant_id position], unique: true
    add_foreign_key :sequence_steps, :variants
  end
end
