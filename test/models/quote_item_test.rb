# frozen_string_literal: true

require "test_helper"

class QuoteItemTest < ActiveSupport::TestCase
  # --- validations ---

  test "validates presence of name" do
    item = QuoteItem.new(quote: quotes(:draft_one), name: nil, quantity: 1, unit_price_cents: 100, vat_rate: 20)
    assert_not item.valid?
    assert item.errors.of_kind?(:name, :blank)
  end

  test "validates quantity is greater than 0" do
    item = QuoteItem.new(quote: quotes(:draft_one), name: "X", quantity: 0, unit_price_cents: 100, vat_rate: 20)
    assert_not item.valid?
    assert item.errors.of_kind?(:quantity, :greater_than)
  end

  test "validates unit_price_cents is non-negative" do
    base = {quote: quotes(:draft_one), name: "X", quantity: 1, vat_rate: 20}
    assert_not QuoteItem.new(base.merge(unit_price_cents: -1)).valid?
    assert QuoteItem.new(base.merge(unit_price_cents: 0)).valid?
    assert QuoteItem.new(base.merge(unit_price_cents: 100)).valid?
  end

  test "validates vat_rate is in 0..100" do
    base = {quote: quotes(:draft_one), name: "X", quantity: 1, unit_price_cents: 100}
    [-1, 101].each do |rate|
      assert_not QuoteItem.new(base.merge(vat_rate: rate)).valid?, "vat_rate=#{rate} should be invalid"
    end
    assert QuoteItem.new(base.merge(vat_rate: 20)).valid?
  end

  test "validates belongs_to quote" do
    item = QuoteItem.new(name: "X", quantity: 1, unit_price_cents: 100, vat_rate: 20)
    assert_not item.valid?
    assert item.errors[:quote].any?
  end

  test "validates parent_quote_must_be_draft" do
    item = quote_items(:beta_audit)
    item.name = "X"
    assert_not item.valid?
    assert item.errors.of_kind?(:base, :quote_validated)
  end

  test "creating an item on a validated quote is blocked" do
    item = quotes(:validated_one).quote_items.build(name: "X", quantity: 1, unit_price_cents: 100, vat_rate: 20)
    assert_not item.valid?
    assert item.errors.of_kind?(:base, :quote_validated)
  end

  # --- #unit_price (getter) ---

  test "#unit_price returns BigDecimal euros from cents" do
    assert_equal BigDecimal("12.5"), QuoteItem.new(unit_price_cents: 1250).unit_price
  end

  test "#unit_price returns nil when cents is nil" do
    assert_nil QuoteItem.new.unit_price
  end

  # --- #unit_price= (setter) ---

  test "#unit_price= parses a string with decimals" do
    item = QuoteItem.new
    item.unit_price = "12.50"
    assert_equal 1250, item.unit_price_cents
  end

  test "#unit_price= parses a numeric" do
    item = QuoteItem.new
    item.unit_price = 0.5
    assert_equal 50, item.unit_price_cents
  end

  test "#unit_price= sets nil cents when given nil or blank" do
    item = QuoteItem.new(unit_price_cents: 999)
    item.unit_price = nil
    assert_nil item.unit_price_cents

    item.unit_price = ""
    assert_nil item.unit_price_cents
  end

  # --- #total_excl_tax_cents ---

  test "#total_excl_tax_cents = quantity × unit_price_cents (rounded)" do
    item = QuoteItem.new(quantity: 3, unit_price_cents: 80_000, vat_rate: 20)
    assert_equal 240_000, item.total_excl_tax_cents
  end

  test "#total_excl_tax_cents returns 0 with missing fields" do
    assert_equal 0, QuoteItem.new.total_excl_tax_cents
  end

  # --- #total_vat_cents ---

  test "#total_vat_cents applies vat_rate" do
    item = QuoteItem.new(quantity: 3, unit_price_cents: 80_000, vat_rate: 20)
    assert_equal 48_000, item.total_vat_cents
  end

  test "#total_vat_cents returns 0 when vat_rate is nil" do
    item = QuoteItem.new(quantity: 3, unit_price_cents: 80_000, vat_rate: nil)
    assert_equal 0, item.total_vat_cents
  end

  # --- #total_incl_tax_cents ---

  test "#total_incl_tax_cents equals HT + VAT" do
    item = QuoteItem.new(quantity: 3, unit_price_cents: 80_000, vat_rate: 20)
    assert_equal item.total_excl_tax_cents + item.total_vat_cents, item.total_incl_tax_cents
  end

  # --- destroy callback ---

  test "destroy is blocked when parent quote is validated" do
    item = quote_items(:beta_audit)
    assert_no_difference("QuoteItem.count") do
      assert_equal false, item.destroy
    end
  end
end
