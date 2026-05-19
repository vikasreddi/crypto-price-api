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

ActiveRecord::Schema[8.1].define(version: 2026_05_19_065855) do
  create_table "crypto_prices", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "coingecko_id"
    t.datetime "created_at", null: false
    t.text "error_message"
    t.integer "failure_count", default: 0, null: false
    t.datetime "fetched_at"
    t.datetime "last_failed_at"
    t.datetime "last_success_at"
    t.decimal "price_usd", precision: 10
    t.integer "status", default: 1, null: false
    t.string "symbol"
    t.datetime "updated_at", null: false
    t.index ["symbol"], name: "index_crypto_prices_on_symbol", unique: true
  end
end
