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

ActiveRecord::Schema[8.1].define(version: 2026_09_18_000000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "holdings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.decimal "market_value", precision: 14, scale: 2, null: false
    t.bigint "portfolio_id", null: false
    t.string "symbol", null: false
    t.decimal "target_percent", precision: 5, scale: 2, null: false
    t.datetime "updated_at", null: false
    t.index ["portfolio_id"], name: "index_holdings_on_portfolio_id"
    t.check_constraint "market_value >= 0::numeric", name: "nonnegative_market_value"
    t.check_constraint "target_percent >= 0::numeric AND target_percent <= 100::numeric", name: "valid_target_percent"
  end

  create_table "portfolios", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "holdings", "portfolios"
end
