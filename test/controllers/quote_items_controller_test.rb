# frozen_string_literal: true

require "test_helper"

class QuoteItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @quote = quotes(:draft_one)
  end

  # --- create ---

  test "creates an item under a draft quote" do
    assert_difference("QuoteItem.count", 1) do
      post quote_quote_items_path(@quote),
        params: { quote_item: { name: "Hébergement", quantity: 12, unit_price: "9.99", vat_rate: 20 } },
        as: :turbo_stream
    end
    assert_response :success
    item = QuoteItem.last
    assert_equal "Hébergement", item.name
    assert_equal 999, item.unit_price_cents
  end

  test "rejects item creation with invalid params" do
    assert_no_difference("QuoteItem.count") do
      post quote_quote_items_path(@quote),
        params: { quote_item: { name: "", quantity: 0, unit_price: "10", vat_rate: 20 } },
        as: :turbo_stream
    end
    assert_response :unprocessable_entity
  end

  test "rejects item creation under a validated quote" do
    validated = quotes(:validated_one)
    assert_no_difference("QuoteItem.count") do
      post quote_quote_items_path(validated),
        params: { quote_item: { name: "X", quantity: 1, unit_price: "10", vat_rate: 20 } },
        as: :turbo_stream
    end
    assert_response :unprocessable_entity
  end

  # --- update ---

  test "updates an item under a draft quote" do
    item = quote_items(:acme_design)
    patch quote_quote_item_path(@quote, item),
      params: { quote_item: { name: "Design v2", quantity: 5, unit_price: "120", vat_rate: 20 } },
      as: :turbo_stream
    assert_response :success
    item.reload
    assert_equal "Design v2", item.name
    assert_equal 5, item.quantity
    assert_equal 12_000, item.unit_price_cents
  end

  test "rejects item update with invalid params" do
    item = quote_items(:acme_design)
    patch quote_quote_item_path(@quote, item),
      params: { quote_item: { name: "", quantity: 1, unit_price: "10", vat_rate: 20 } },
      as: :turbo_stream
    assert_response :unprocessable_entity
    assert_equal "Design maquettes", item.reload.name
  end

  # --- destroy ---

  test "destroys an item under a draft quote" do
    item = quote_items(:acme_design)
    assert_difference("QuoteItem.count", -1) do
      delete quote_quote_item_path(@quote, item), as: :turbo_stream
    end
    assert_response :success
  end

  test "does not destroy an item under a validated quote" do
    item = quote_items(:beta_audit)
    validated = quotes(:validated_one)
    assert_no_difference("QuoteItem.count") do
      delete quote_quote_item_path(validated, item), as: :turbo_stream
    end
  end
end
