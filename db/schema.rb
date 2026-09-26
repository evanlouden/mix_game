# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_09_25_004000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "hand_rules", force: :cascade do |t|
    t.string "ace_behavior"
    t.integer "community_cards_required"
    t.datetime "created_at", null: false
    t.string "direction"
    t.integer "hand_size", default: 5
    t.string "hand_type"
    t.integer "hole_cards_required"
    t.text "notes"
    t.integer "pot_number", default: 1, null: false
    t.string "qualifier"
    t.string "rule", default: "standard_high", null: false
    t.string "source_pages"
    t.datetime "updated_at", null: false
    t.bigint "variant_id", null: false
    t.index ["ace_behavior"], name: "index_hand_rules_on_ace_behavior"
    t.index ["variant_id", "pot_number"], name: "index_hand_rules_on_variant_id_and_pot_number"
    t.index ["variant_id"], name: "index_hand_rules_on_variant_id"
  end

  create_table "sequence_steps", force: :cascade do |t|
    t.string "action_type", null: false
    t.string "card_scope"
    t.integer "cards_down"
    t.integer "cards_up"
    t.datetime "created_at", null: false
    t.integer "max_cards"
    t.integer "min_cards"
    t.integer "number_of_boards"
    t.integer "position", null: false
    t.datetime "updated_at", null: false
    t.bigint "variant_id", null: false
    t.index ["action_type"], name: "index_sequence_steps_on_action_type"
    t.index ["variant_id", "position"], name: "index_sequence_steps_on_variant_id_and_position", unique: true
    t.index ["variant_id"], name: "index_sequence_steps_on_variant_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "variants", force: :cascade do |t|
    t.text "action_order"
    t.text "best_hand"
    t.string "betting_format"
    t.text "betting_structure"
    t.text "bring_in"
    t.boolean "confirmed", default: false, null: false
    t.datetime "created_at", null: false
    t.text "deck_modification"
    t.string "family", null: false
    t.text "final_hand"
    t.text "forced_bet"
    t.text "high_hand"
    t.text "low_hand"
    t.text "max_players"
    t.string "name", null: false
    t.text "pot_1_hand_rule"
    t.string "pot_1_qualifier"
    t.text "pot_2_hand_rule"
    t.string "pot_2_qualifier"
    t.text "qualifier"
    t.jsonb "source_detail", default: {}, null: false
    t.string "source_id"
    t.text "source_notes"
    t.text "source_pages"
    t.text "special_mechanics"
    t.text "split_pot"
    t.integer "starting_cards_down"
    t.integer "starting_cards_up"
    t.datetime "updated_at", null: false
    t.text "wild_cards"
    t.index ["family"], name: "index_variants_on_family"
    t.index ["source_id"], name: "index_variants_on_source_id", unique: true
  end

  add_foreign_key "hand_rules", "variants"
  add_foreign_key "sequence_steps", "variants"
end
