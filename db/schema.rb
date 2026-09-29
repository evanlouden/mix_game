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

ActiveRecord::Schema[8.1].define(version: 2026_09_26_017000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

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
    t.boolean "bomb_pot", default: false, null: false
    t.text "bring_in"
    t.datetime "created_at", null: false
    t.string "family", null: false
    t.boolean "fixed_limit", default: false, null: false
    t.text "forced_bet"
    t.text "max_players"
    t.string "name", null: false
    t.boolean "no_limit", default: false, null: false
    t.text "pot_1_hand_rule"
    t.string "pot_1_qualifier"
    t.text "pot_2_hand_rule"
    t.string "pot_2_qualifier"
    t.boolean "pot_limit", default: false, null: false
    t.text "special_mechanics"
    t.datetime "updated_at", null: false
    t.index ["family"], name: "index_variants_on_family"
  end

  add_foreign_key "sequence_steps", "variants"
end
