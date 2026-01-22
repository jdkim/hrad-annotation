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

ActiveRecord::Schema[8.0].define(version: 2026_01_21_235738) do
  create_table "medical_cases", force: :cascade do |t|
    t.string "case_id"
    t.text "report_text"
    t.text "causal_exploration_text"
    t.json "checklist_data"
    t.json "image_paths"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["case_id"], name: "index_medical_cases_on_case_id", unique: true
  end

  create_table "structured_causal_explanations", force: :cascade do |t|
    t.integer "medical_case_id", null: false
    t.integer "user_id", null: false
    t.string "finding"
    t.string "impression"
    t.boolean "certainty"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["medical_case_id"], name: "index_structured_causal_explanations_on_medical_case_id"
    t.index ["user_id"], name: "index_structured_causal_explanations_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "name"
    t.string "google_uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email"
    t.index ["google_uid"], name: "index_users_on_google_uid", unique: true
  end

  add_foreign_key "structured_causal_explanations", "medical_cases"
  add_foreign_key "structured_causal_explanations", "users"
end
