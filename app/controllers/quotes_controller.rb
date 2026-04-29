# frozen_string_literal: true

class QuotesController < ApplicationController
  before_action :set_quote, only: %i[destroy validate]

  def index
    @quotes = Quote.order(created_at: :asc)
  end

  def new
    @quote = Quote.new
  end

  def create
    @quote = Quote.new(quote_params)
    if @quote.save
      respond_to do |format|
        format.turbo_stream
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @quote.destroy
    respond_to do |format|
      format.turbo_stream
    end
  end

  def validate
    @quote.mark_as_validated! unless @quote.validated?
    redirect_to quotes_path, notice: "Facture validé"
  end

  private

  def set_quote
    @quote = Quote.find(params[:id])
  end

  def quote_params
    params.require(:quote).permit(:name)
  end
end
