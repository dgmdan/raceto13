# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150506041603) do

  create_table "entries", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "league_id"
    t.integer  "team_id"
    t.datetime "paid_at"
    t.datetime "cancelled_at"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.datetime "won_at"
    t.integer  "won_place"
  end

  add_index "entries", ["league_id"], name: "index_entries_on_league_id"
  add_index "entries", ["team_id"], name: "index_entries_on_team_id"
  add_index "entries", ["user_id"], name: "index_entries_on_user_id"

  create_table "games", force: :cascade do |t|
    t.date     "started_on"
    t.integer  "home_team_id"
    t.integer  "away_team_id"
    t.integer  "home_score"
    t.integer  "away_score"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "hits", force: :cascade do |t|
    t.integer  "entry_id"
    t.integer  "runs"
    t.date     "hit_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "hits", ["entry_id"], name: "index_hits_on_entry_id"

  create_table "league_users", force: :cascade do |t|
    t.integer  "league_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "league_users", ["league_id"], name: "index_league_users_on_league_id"
  add_index "league_users", ["user_id"], name: "index_league_users_on_user_id"

  create_table "leagues", force: :cascade do |t|
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "leagues", ["user_id"], name: "index_leagues_on_user_id"

  create_table "notification_type_users", force: :cascade do |t|
    t.integer  "notification_type_id"
    t.integer  "user_id"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "notification_types", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "description"
  end

  create_table "teams", force: :cascade do |t|
    t.string   "name"
    t.string   "data_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "teams", ["data_name"], name: "index_teams_on_data_name", unique: true

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin",                  default: false
    t.string   "name"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
