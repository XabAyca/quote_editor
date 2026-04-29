# frozen_string_literal: true

class QuoteItemsController < ApplicationController
  before_action :set_quote
  before_action :set_quote_item, except: %i[index new create]

  def index
    @quote_items = @quote.quote_items.order(created_at: :asc)
  end

  def new
    @quote_item = QuoteItem.new
  end

  def create
    @quote_item = @quote.quote_items.build(quote_item_params)
    if @quote_item.save
      respond_to do |format|
        format.turbo_stream
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @quote_item.update(quote_item_params)
      respond_to do |format|
        format.turbo_stream
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @quote_item.destroy
    respond_to do |format|
      format.turbo_stream
    end
  end

  private

  def set_quote
    @quote = Quote.find(params[:quote_id])
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  def set_quote_item
    @quote_item = @quote.quote_items.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  def quote_item_params
    params.require(:quote_item).permit(
      :name,
      :quantity,
      :unit_price,
      :vat_rate
    )
  end
end
