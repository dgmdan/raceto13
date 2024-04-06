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

ActiveRecord::Schema[7.1].define(version: 2024_04_06_150109) do
  create_table "entries", force: :cascade do |t|
    t.integer "user_id"
    t.integer "league_id"
    t.integer "team_id"
    t.datetime "paid_at", precision: nil
    t.datetime "cancelled_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "won_at", precision: nil
    t.integer "won_place"
    t.integer "game_count"
    t.index ["league_id"], name: "index_entries_on_league_id"
    t.index ["team_id"], name: "index_entries_on_team_id"
    t.index ["user_id"], name: "index_entries_on_user_id"
  end

  create_table "games", force: :cascade do |t|
    t.date "started_on"
    t.integer "home_team_id"
    t.integer "away_team_id"
    t.integer "home_score"
    t.integer "away_score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "hits", force: :cascade do |t|
    t.integer "entry_id"
    t.integer "runs"
    t.date "hit_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "game_id"
    t.index ["entry_id"], name: "index_hits_on_entry_id"
    t.index ["game_id"], name: "index_hits_on_game_id"
  end

  create_table "league_users", force: :cascade do |t|
    t.integer "league_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["league_id"], name: "index_league_users_on_league_id"
    t.index ["user_id"], name: "index_league_users_on_user_id"
  end

  create_table "leagues", force: :cascade do |t|
    t.string "name"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "starts_at", precision: nil
    t.datetime "ends_at", precision: nil
    t.string "invite_uuid"
    t.index ["invite_uuid"], name: "index_leagues_on_invite_uuid"
    t.index ["user_id"], name: "index_leagues_on_user_id"
  end

  create_table "notification_type_users", force: :cascade do |t|
    t.integer "notification_type_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notification_type_id"], name: "index_notification_type_users_on_notification_type_id"
    t.index ["user_id"], name: "index_notification_type_users_on_user_id"
  end

  create_table "notification_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "description"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name"
    t.string "data_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["data_name"], name: "index_teams_on_data_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin", default: false
    t.string "name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "entries", "leagues"
  add_foreign_key "entries", "teams"
  add_foreign_key "entries", "users"
  add_foreign_key "hits", "entries"
  add_foreign_key "league_users", "leagues"
  add_foreign_key "league_users", "users"
  add_foreign_key "leagues", "users"
end
