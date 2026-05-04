# frozen_string_literal: true

require "test_helper"

class QuotesControllerTest < ActionDispatch::IntegrationTest
  # --- create ---

  test "creates a quote with valid params" do
    assert_difference("Quote.count", 1) do
      post quotes_path, params: { quote: { name: "Nouveau devis" } }, as: :turbo_stream
    end
    assert_response :success
    assert_equal "Nouveau devis", Quote.last.name
  end

  test "rejects creation with blank name" do
    assert_no_difference("Quote.count") do
      post quotes_path, params: { quote: { name: "" } }, as: :turbo_stream
    end
    assert_response :unprocessable_entity
  end

  # --- destroy ---

  test "destroys a draft quote" do
    quote = quotes(:draft_one)
    assert_difference("Quote.count", -1) do
      delete quote_path(quote), as: :turbo_stream
    end
    assert_response :success
  end

  test "does not destroy a validated quote" do
    quote = quotes(:validated_one)
    assert_no_difference("Quote.count") do
      delete quote_path(quote), as: :turbo_stream
    end
  end

  # --- show ---

  test "shows a quote as turbo stream" do
    quote = quotes(:draft_one)
    get quote_path(quote), as: :turbo_stream
    assert_response :success
  end

  # --- edit ---

  test "renders the edit form as turbo stream" do
    quote = quotes(:draft_one)
    get edit_quote_path(quote), as: :turbo_stream
    assert_response :success
  end

  # --- update ---

  test "updates a quote name with valid params" do
    quote = quotes(:draft_one)
    patch quote_path(quote), params: { quote: { name: "Nom modifié" } }, as: :turbo_stream
    assert_response :success
    assert_equal "Nom modifié", quote.reload.name
  end

  test "rejects update with blank name" do
    quote = quotes(:draft_one)
    original_name = quote.name
    patch quote_path(quote), params: { quote: { name: "" } }, as: :turbo_stream
    assert_response :unprocessable_entity
    assert_equal original_name, quote.reload.name
  end

  test "does not update a validated quote" do
    quote = quotes(:validated_one)
    original_name = quote.name
    patch quote_path(quote), params: { quote: { name: "Nom modifié" } }, as: :turbo_stream
    assert_response :unprocessable_entity
    assert_equal original_name, quote.reload.name
  end
end
