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

ActiveRecord::Schema[7.0].define(version: 2024_11_09_212140) do
  create_table "hike_histories", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.date "hiking_date"
    t.string "departure_time"
    t.string "day_type"
    t.integer "difficulty"
    t.string "starting_point"
    t.string "trail_name"
    t.decimal "carpooling_cost", precision: 5, scale: 2
    t.decimal "distance_km", precision: 5, scale: 2
    t.integer "elevation_gain"
    t.string "guide_name"
    t.string "guide_phone"
    t.integer "hike_number"
    t.string "openrunner_ref"
    t.string "openrunner_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["hike_number"], name: "index_hike_histories_on_hike_number"
    t.index ["hiking_date", "hike_number"], name: "index_hike_histories_on_hiking_date_and_hike_number", unique: true
  end

  create_table "hikes", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "number", null: false
    t.integer "day", null: false
    t.integer "difficulty"
    t.string "starting_point"
    t.string "trail_name"
    t.integer "carpooling_cost"
    t.decimal "distance_km", precision: 5, scale: 2
    t.integer "elevation_gain"
    t.string "openrunner_ref"
    t.date "last_schedule"
    t.string "openrunner_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["number"], name: "index_hikes_on_number", unique: true
  end

end
