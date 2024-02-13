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

ActiveRecord::Schema.define(version: 2019_01_20_122354) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "course_settings", id: false, force: :cascade do |t|
    t.uuid "course_id"
    t.string "type"
    t.text "value"
    t.boolean "grouping_enabled", default: true, null: false
  end

  create_table "courses", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "name"
    t.string "auth_key"
    t.string "auth_secret"
    t.string "url"
    t.string "platform_id"
    t.integer "enrollments_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "workflow_state"
    t.boolean "updating_scores", default: false, null: false
    t.boolean "grouping_teams", default: false, null: false
    t.index ["platform_id", "id"], name: "index_courses_on_platform_id_and_id", unique: true
  end

  create_table "enrollments", id: :serial, force: :cascade do |t|
    t.uuid "user_id"
    t.uuid "course_id"
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "team_id"
    t.string "name"
    t.string "email"
    t.float "score"
  end

  create_table "teams", id: :serial, force: :cascade do |t|
    t.string "name"
    t.uuid "course_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "collab_space_id"
    t.boolean "approved", default: false, null: false
    t.text "note"
    t.index ["course_id"], name: "index_teams_on_course_id"
  end

end
