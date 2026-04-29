class CreateQuoteItems < ActiveRecord::Migration[7.2]
  def change
    create_table :quote_items do |t|
      t.references :quote, null: false, foreign_key: { on_delete: :cascade }
      t.string  :name, null: false
      t.decimal :quantity, precision: 10, scale: 2, null: false
      t.integer :unit_price_cents, null: false
      t.decimal :vat_rate, precision: 5, scale: 2, null: false
      t.timestamps
    end

    add_check_constraint :quote_items, "quantity > 0", name: "quote_items_quantity_positive"
    add_check_constraint :quote_items, "unit_price_cents >= 0", name: "quote_items_unit_price_cents_non_negative"
    add_check_constraint :quote_items, "vat_rate >= 0 AND vat_rate <= 100", name: "quote_items_vat_rate_range"
  end
end
