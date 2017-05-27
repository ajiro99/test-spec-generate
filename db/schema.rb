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

ActiveRecord::Schema.define(version: 20160913161036) do

  create_table "projects", force: :cascade do |t|
    t.string   "project_name", null: false
    t.text     "description"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "scenarios", force: :cascade do |t|
    t.integer  "project_id"
    t.string   "scenario_name",                 null: false
    t.integer  "scenario_no",                   null: false
    t.text     "description"
    t.integer  "count_item",        default: 0
    t.integer  "count_item_target", default: 0
    t.integer  "count_remaining",   default: 0
    t.integer  "count_ok",          default: 0
    t.integer  "count_ng",          default: 0
    t.text     "input_scenario",                null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "scenarios", ["project_id"], name: "index_scenarios_on_project_id"

  create_table "test_cases", force: :cascade do |t|
    t.integer  "scenario_id"
    t.integer  "test_case_no",  null: false
    t.string   "screen_name"
    t.text     "test_content"
    t.text     "check_content"
    t.text     "description"
    t.string   "status"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "test_cases", ["scenario_id"], name: "index_test_cases_on_scenario_id"

end
