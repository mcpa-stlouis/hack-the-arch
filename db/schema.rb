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

ActiveRecord::Schema.define(version: 20170329223140) do

  create_table "brackets", force: :cascade do |t|
    t.string   "name"
    t.integer  "priority"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "hints_available", default: 0
  end

  create_table "caches", force: :cascade do |t|
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "key"
    t.string   "value"
    t.boolean  "cache_valid"
  end

  create_table "hint_requests", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "team_id"
    t.integer  "user_id"
    t.integer  "hint_id"
    t.integer  "points"
    t.integer  "problem_id"
    t.index ["problem_id"], name: "index_hint_requests_on_problem_id"
    t.index ["team_id"], name: "index_hint_requests_on_team_id"
    t.index ["user_id"], name: "index_hint_requests_on_user_id"
  end

  create_table "hints", force: :cascade do |t|
    t.string   "hint"
    t.integer  "points"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "pointer_counter"
    t.integer  "priority"
  end

  create_table "messages", force: :cascade do |t|
    t.string   "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "user_id"
    t.string   "priority"
    t.string   "url"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "problems", force: :cascade do |t|
    t.integer  "points"
    t.string   "category"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "name"
    t.string   "description"
    t.string   "solution"
    t.string   "correct_message"
    t.string   "false_message"
    t.string   "hints"
    t.string   "picture"
    t.boolean  "visible"
    t.boolean  "solution_case_sensitive"
    t.integer  "parent_problem_id"
    t.index ["parent_problem_id"], name: "index_problems_on_parent_problem_id"
  end

  create_table "settings", force: :cascade do |t|
    t.string   "name"
    t.string   "value"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "setting_type"
    t.string   "category"
    t.string   "label"
    t.string   "tooltip"
  end

  create_table "submissions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "team_id"
    t.integer  "user_id"
    t.boolean  "correct"
    t.integer  "problem_id"
    t.integer  "points"
    t.string   "submission"
    t.index ["problem_id"], name: "index_submissions_on_problem_id"
    t.index ["team_id"], name: "index_submissions_on_team_id"
    t.index ["user_id"], name: "index_submissions_on_user_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "passphrase"
    t.integer  "bracket_id"
    t.index ["bracket_id"], name: "index_teams_on_bracket_id"
  end

  create_table "users", force: :cascade do |t|
    t.string   "fname"
    t.string   "lname"
    t.string   "email"
    t.integer  "team_id"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "password_digest"
    t.string   "remember_digest"
    t.boolean  "admin",             default: false
    t.string   "activation_digest"
    t.boolean  "activated",         default: false
    t.datetime "activated_at"
    t.string   "reset_digest"
    t.datetime "reset_sent_at"
    t.boolean  "paid"
    t.string   "discount_code"
    t.string   "username"
    t.boolean  "authorized",        default: false
    t.datetime "authorized_at"
    t.index ["team_id"], name: "index_users_on_team_id"
  end

end
