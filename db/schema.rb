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

ActiveRecord::Schema[7.2].define(version: 2026_04_27_190137) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "quote_items", force: :cascade do |t|
    t.bigint "quote_id", null: false
    t.string "name", null: false
    t.decimal "quantity", precision: 10, scale: 2, null: false
    t.integer "unit_price_cents", null: false
    t.decimal "vat_rate", precision: 5, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["quote_id"], name: "index_quote_items_on_quote_id"
    t.check_constraint "quantity > 0::numeric", name: "quote_items_quantity_positive"
    t.check_constraint "unit_price_cents >= 0", name: "quote_items_unit_price_cents_non_negative"
    t.check_constraint "vat_rate >= 0::numeric AND vat_rate <= 100::numeric", name: "quote_items_vat_rate_range"
  end

  create_table "quotes", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "validated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["validated_at"], name: "index_quotes_on_validated_at"
  end

  add_foreign_key "quote_items", "quotes", on_delete: :cascade
end
