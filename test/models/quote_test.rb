# frozen_string_literal: true

require "test_helper"

class QuoteTest < ActiveSupport::TestCase
  # --- validations ---

  test "validates presence of name" do
    quote = Quote.new(name: nil)
    assert_not quote.valid?
    assert_includes quote.errors[:name], "can't be blank"
  end

  # --- #validated? ---

  test "#validated? is false when validated_at is nil" do
    assert_not quotes(:draft_one).validated?
  end

  test "#validated? is true when validated_at is set" do
    assert quotes(:validated_one).validated?
  end

  # --- #mark_as_validated! ---

  test "#mark_as_validated! stamps validated_at and makes record validated?" do
    quote = quotes(:draft_one)
    assert_nil quote.validated_at
    quote.mark_as_validated!
    assert_not_nil quote.validated_at
    assert quote.validated?
  end

  # --- #readonly? ---

  test "#readonly? is false on a draft" do
    assert_not quotes(:draft_one).readonly?
  end

  test "#readonly? is true on a validated quote" do
    assert quotes(:validated_one).readonly?
  end

  test "#readonly? is false during the validation save (carve-out)" do
    quote = quotes(:draft_one)
    quote.validated_at = Time.current
    assert_not quote.readonly?
    assert quote.save
  end

  # --- #total_excl_tax_cents ---

  test "#total_excl_tax_cents sums items" do
    # 3 × 80000 + 10.5 × 60000 = 240000 + 630000
    assert_equal 870_000, quotes(:draft_one).total_excl_tax_cents
  end

  test "#total_excl_tax_cents returns 0 without items" do
    assert_equal 0, Quote.create!(name: "Empty").total_excl_tax_cents
  end

  # --- #total_vat_cents ---

  test "#total_vat_cents sums items VAT" do
    # acme_design VAT: 240000 × 20 / 100 = 48000
    # acme_dev    VAT: 630000 × 20 / 100 = 126000
    assert_equal 174_000, quotes(:draft_one).total_vat_cents
  end

  test "#total_vat_cents returns 0 without items" do
    assert_equal 0, Quote.create!(name: "Empty").total_vat_cents
  end

  # --- #total_incl_tax_cents ---

  test "#total_incl_tax_cents equals HT + VAT" do
    quote = quotes(:draft_one)
    assert_equal quote.total_excl_tax_cents + quote.total_vat_cents, quote.total_incl_tax_cents
  end

  # --- destroy callback ---

  test "destroy cascades to items on a draft" do
    quote = quotes(:draft_one)
    items_count = quote.quote_items.count
    assert_difference("Quote.count", -1) do
      assert_difference("QuoteItem.count", -items_count) do
        quote.destroy
      end
    end
  end

  test "destroy is blocked on a validated quote" do
    quote = quotes(:validated_one)
    assert_no_difference("Quote.count") do
      assert_equal false, quote.destroy
    end
  end

  # --- update path ---

  test "update! raises ReadOnlyRecord on a validated quote" do
    quote = quotes(:validated_one)
    assert_raises(ActiveRecord::ReadOnlyRecord) { quote.update!(name: "X") }
  end
end
