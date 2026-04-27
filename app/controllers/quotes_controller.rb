# frozen_string_literal: true

class QuotesController < ApplicationController
  def index
    @quotes = Quote.order(created_at: :desc)
  end

  def show
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end

  def validate
  end
end
