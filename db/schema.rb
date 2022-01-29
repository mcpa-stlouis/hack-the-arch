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

ActiveRecord::Schema.define(version: 2022_01_29_142627) do

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.integer "record_id", null: false
    t.integer "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.integer "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "brackets", force: :cascade do |t|
    t.string "name"
    t.integer "priority"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "hints_available", default: 0
  end

  create_table "caches", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "key"
    t.string "value"
    t.boolean "cache_valid"
  end

  create_table "hint_requests", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "team_id"
    t.integer "user_id"
    t.integer "hint_id"
    t.integer "points"
    t.integer "problem_id"
    t.index ["problem_id"], name: "index_hint_requests_on_problem_id"
    t.index ["team_id"], name: "index_hint_requests_on_team_id"
    t.index ["user_id"], name: "index_hint_requests_on_user_id"
  end

  create_table "hints", force: :cascade do |t|
    t.string "hint"
    t.integer "points"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "pointer_counter"
    t.integer "priority"
  end

  create_table "messages", force: :cascade do |t|
    t.string "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.string "priority"
    t.string "url"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "problems", force: :cascade do |t|
    t.integer "points"
    t.string "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "description"
    t.string "solution"
    t.string "correct_message"
    t.string "false_message"
    t.string "hints"
    t.string "picture"
    t.boolean "visible"
    t.boolean "solution_case_sensitive"
    t.integer "parent_problem_id"
    t.boolean "solution_regex"
    t.string "stack"
    t.string "network"
    t.boolean "vnc"
    t.index ["parent_problem_id"], name: "index_problems_on_parent_problem_id"
  end

  create_table "settings", force: :cascade do |t|
    t.string "name"
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "setting_type"
    t.string "category"
    t.string "label"
    t.string "tooltip"
  end

  create_table "submissions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "team_id"
    t.integer "user_id"
    t.boolean "correct"
    t.integer "problem_id"
    t.integer "points"
    t.string "submission"
    t.index ["problem_id"], name: "index_submissions_on_problem_id"
    t.index ["team_id"], name: "index_submissions_on_team_id"
    t.index ["user_id"], name: "index_submissions_on_user_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "passphrase"
    t.integer "bracket_id"
    t.index ["bracket_id"], name: "index_teams_on_bracket_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "fname"
    t.string "lname"
    t.string "email"
    t.integer "team_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "remember_digest"
    t.boolean "admin", default: false
    t.string "activation_digest"
    t.boolean "activated", default: false
    t.datetime "activated_at"
    t.string "reset_digest"
    t.datetime "reset_sent_at"
    t.boolean "paid"
    t.string "discount_code"
    t.string "username"
    t.boolean "authorized", default: false
    t.datetime "authorized_at"
    t.datetime "last_submission"
    t.string "about"
    t.datetime "stack_expiry"
    t.string "container_id"
    t.integer "problem_id"
    t.index ["team_id"], name: "index_users_on_team_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "messages", "users"
end
