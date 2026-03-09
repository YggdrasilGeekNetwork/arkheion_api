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

ActiveRecord::Schema[8.0].define(version: 2026_03_09_133148) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "tormenta20_character_sheets", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "campaign_id"
    t.string "name", null: false
    t.string "race_key", null: false
    t.string "origin_key", null: false
    t.string "deity_key"
    t.jsonb "sheet_attributes", default: {}, null: false
    t.jsonb "race_choices", default: {}, null: false
    t.jsonb "origin_choices", default: {}, null: false
    t.jsonb "proficiencies", default: {}, null: false
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image_url"
    t.integer "character_version", default: 0, null: false
    t.index ["name"], name: "index_tormenta20_character_sheets_on_name"
    t.index ["race_key"], name: "index_tormenta20_character_sheets_on_race_key"
    t.index ["user_id", "campaign_id"], name: "index_tormenta20_character_sheets_on_user_id_and_campaign_id"
    t.index ["user_id"], name: "index_tormenta20_character_sheets_on_user_id"
  end

  create_table "tormenta20_character_snapshots", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "character_sheet_id", null: false
    t.integer "version", null: false
    t.string "checksum", null: false
    t.jsonb "computed_attributes", default: {}, null: false
    t.jsonb "computed_defenses", default: {}, null: false
    t.jsonb "computed_skills", default: {}, null: false
    t.jsonb "computed_combat", default: {}, null: false
    t.jsonb "computed_resources", default: {}, null: false
    t.jsonb "computed_abilities", default: {}, null: false
    t.jsonb "computed_spells", default: {}, null: false
    t.jsonb "computed_proficiencies", default: {}, null: false
    t.jsonb "full_snapshot", default: {}, null: false
    t.datetime "computed_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "computed_senses", default: [], null: false
    t.index ["character_sheet_id", "version"], name: "idx_snapshots_on_sheet_and_version", unique: true
    t.index ["character_sheet_id"], name: "index_tormenta20_character_snapshots_on_character_sheet_id"
    t.index ["checksum"], name: "index_tormenta20_character_snapshots_on_checksum"
    t.index ["computed_at"], name: "index_tormenta20_character_snapshots_on_computed_at"
  end

  create_table "tormenta20_character_states", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "character_sheet_id", null: false
    t.integer "current_pv", default: 0, null: false
    t.integer "current_pm", default: 0, null: false
    t.integer "temporary_pv", default: 0, null: false
    t.jsonb "equipped_items", default: {}, null: false
    t.jsonb "active_conditions", default: [], null: false
    t.jsonb "active_effects", default: [], null: false
    t.jsonb "consumable_uses", default: {}, null: false
    t.jsonb "spell_slots_used", default: {}, null: false
    t.jsonb "ability_uses", default: {}, null: false
    t.jsonb "inventory", default: [], null: false
    t.jsonb "currency", default: {}, null: false
    t.jsonb "notes", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "available_actions_data", default: {}, null: false
    t.integer "initiative_roll_value"
    t.boolean "in_combat", default: false, null: false
    t.boolean "is_my_turn", default: false, null: false
    t.integer "turn_order", default: 0, null: false
    t.index ["character_sheet_id"], name: "index_tormenta20_character_states_on_character_sheet_id"
  end

  create_table "tormenta20_level_ups", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "character_sheet_id", null: false
    t.integer "level", null: false
    t.string "class_key", null: false
    t.jsonb "class_choices", default: {}, null: false
    t.jsonb "skill_points", default: {}, null: false
    t.jsonb "abilities_chosen", default: {}, null: false
    t.jsonb "powers_chosen", default: {}, null: false
    t.jsonb "spells_chosen", default: {}, null: false
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_sheet_id", "level"], name: "index_tormenta20_level_ups_on_character_sheet_id_and_level", unique: true
    t.index ["character_sheet_id"], name: "index_tormenta20_level_ups_on_character_sheet_id"
    t.index ["class_key"], name: "index_tormenta20_level_ups_on_class_key"
    t.index ["level"], name: "index_tormenta20_level_ups_on_level"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "username", null: false
    t.string "display_name"
    t.string "jti", null: false
    t.datetime "token_expires_at"
    t.boolean "active", default: true, null: false
    t.datetime "confirmed_at"
    t.string "confirmation_token"
    t.datetime "confirmation_sent_at"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.jsonb "preferences", default: {}, null: false
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "tormenta20_character_sheets", "users"
  add_foreign_key "tormenta20_character_snapshots", "tormenta20_character_sheets", column: "character_sheet_id"
  add_foreign_key "tormenta20_character_states", "tormenta20_character_sheets", column: "character_sheet_id"
  add_foreign_key "tormenta20_level_ups", "tormenta20_character_sheets", column: "character_sheet_id"
end
