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

ActiveRecord::Schema[7.0].define(version: 2025_01_16_233933) do
  create_table "hike_histories", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.date "hiking_date"
    t.string "departure_time"
    t.string "day_type"
    t.decimal "carpooling_cost", precision: 5, scale: 2
    t.integer "hike_id"
    t.string "openrunner_ref"
    t.integer "member_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "organisation_id"
    t.index ["hike_id"], name: "index_hike_histories_on_hike_id"
    t.index ["hiking_date", "hike_id"], name: "index_hike_histories_on_hiking_date_and_hike_id", unique: true
  end

  create_table "hike_paths", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.integer "hike_id"
    t.text "coordinates"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "organisation_id"
  end

  create_table "hikes", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.integer "number"
    t.integer "day"
    t.integer "difficulty"
    t.string "starting_point"
    t.string "trail_name"
    t.float "carpooling_cost"
    t.float "distance_km"
    t.float "elevation_gain"
    t.string "openrunner_ref"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "elevation_loss"
    t.integer "altitude_min"
    t.integer "altitude_max"
    t.boolean "updating", default: false
    t.datetime "last_update_attempt"
    t.integer "organisation_id"
  end

  create_table "members", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "phone"
    t.integer "role_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "organisation_id"
  end

  create_table "organisation_access_requests", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.integer "user_id"
    t.integer "organisation_id"
    t.text "message"
    t.string "role"
    t.string "status"
    t.text "admin_response"
    t.integer "processed_by_id"
    t.datetime "processed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "organisations", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.string "url"
    t.string "logo_url"
    t.string "description"
    t.string "location"
    t.string "email"
    t.string "phone"
    t.string "contact_name"
    t.string "contact_email"
    t.string "contact_phone"
    t.string "contact_position"
    t.string "contact_language"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_organisations_on_name", unique: true
  end

  create_table "profile_rights", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.bigint "profile_id", null: false
    t.string "resource", null: false
    t.string "action", null: false
    t.boolean "authorized", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "organisation_id"
    t.index ["profile_id", "resource", "action"], name: "index_profile_rights_on_profile_id_and_resource_and_action", unique: true
    t.index ["profile_id"], name: "index_profile_rights_on_profile_id"
  end

  create_table "profiles", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "organisation_id"
    t.index ["name", "organisation_id"], name: "index_profiles_on_name_and_organisation_id", unique: true
  end

  create_table "rights", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.integer "role_id"
    t.string "model"
    t.boolean "create"
    t.boolean "read"
    t.boolean "update"
    t.boolean "delete"
  end

  create_table "roles", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "organisation_id"
  end

  create_table "user_members", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.integer "user_id"
    t.integer "member_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_organisations", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.integer "user_id"
    t.integer "organisation_id"
    t.integer "profile_id"
    t.boolean "creator", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "theme"
    t.boolean "super_admin", default: false
    t.integer "current_organisation_id"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  add_foreign_key "profile_rights", "profiles"
end
