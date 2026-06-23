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

ActiveRecord::Schema[8.1].define(version: 2026_06_23_200000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "appointments", force: :cascade do |t|
    t.bigint "barber_id"
    t.bigint "barbershop_id", null: false
    t.datetime "created_at", null: false
    t.bigint "customer_id"
    t.text "notes"
    t.boolean "paid"
    t.integer "points", default: 1, null: false
    t.bigint "service_id", null: false
    t.datetime "updated_at", null: false
    t.index ["barbershop_id"], name: "index_appointments_on_barbershop_id"
    t.index ["service_id"], name: "index_appointments_on_service_id"
  end

  create_table "barbershops", force: :cascade do |t|
    t.string "address"
    t.datetime "created_at", null: false
    t.string "name"
    t.string "phone"
    t.datetime "updated_at", null: false
  end

  create_table "loyalty_programs", force: :cascade do |t|
    t.bigint "barbershop_id", null: false
    t.datetime "created_at", null: false
    t.integer "required_visits"
    t.string "reward_description"
    t.datetime "updated_at", null: false
    t.index ["barbershop_id"], name: "index_loyalty_programs_on_barbershop_id"
  end

  create_table "rewards", force: :cascade do |t|
    t.bigint "barbershop_id", null: false
    t.datetime "created_at", null: false
    t.bigint "customer_id"
    t.string "description"
    t.datetime "earned_at"
    t.datetime "updated_at", null: false
    t.boolean "used"
    t.datetime "used_at"
    t.index ["barbershop_id"], name: "index_rewards_on_barbershop_id"
  end

  create_table "services", force: :cascade do |t|
    t.boolean "active", default: true
    t.bigint "barbershop_id", null: false
    t.datetime "created_at", null: false
    t.string "name"
    t.integer "points", default: 1, null: false
    t.datetime "updated_at", null: false
    t.index ["barbershop_id"], name: "index_services_on_barbershop_id"
  end

  create_table "users", force: :cascade do |t|
    t.bigint "barbershop_id", null: false
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name"
    t.string "password_digest"
    t.string "phone"
    t.string "role"
    t.datetime "updated_at", null: false
    t.index ["barbershop_id"], name: "index_users_on_barbershop_id"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "appointments", "barbershops"
  add_foreign_key "appointments", "services"
  add_foreign_key "loyalty_programs", "barbershops"
  add_foreign_key "rewards", "barbershops"
  add_foreign_key "services", "barbershops"
  add_foreign_key "users", "barbershops"
end
