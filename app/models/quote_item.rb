# frozen_string_literal: true

# A single line of a quote. Inherits immutability from its parent quote once it is validated.
class QuoteItem < ApplicationRecord
  belongs_to :quote, inverse_of: :quote_items

  validates :name, presence: true
  validates :quantity, numericality: {greater_than: 0}
  validates :unit_price_cents, numericality: {only_integer: true, greater_than_or_equal_to: 0}
  validates :vat_rate, numericality: {in: 0..100}
  validate :parent_quote_must_be_draft, on: %i[create update]

  before_destroy :prevent_destroy_if_quote_validated

  def unit_price
    return nil if unit_price_cents.nil?
    BigDecimal(unit_price_cents) / 100
  end

  def unit_price=(value)
    self.unit_price_cents =
      if value.nil? || value.to_s.strip.empty?
        nil
      else
        (BigDecimal(value.to_s) * 100).to_i
      end
  end

  def readonly?
    quote&.validated? && persisted?
  end

  def total_excl_tax_cents
    return 0 if quantity.nil? || unit_price_cents.nil?
    (quantity * unit_price_cents).round
  end

  def total_vat_cents
    return 0 if vat_rate.nil?
    (total_excl_tax_cents * vat_rate / 100).round
  end

  def total_incl_tax_cents
    total_excl_tax_cents + total_vat_cents
  end

  private

  def parent_quote_must_be_draft
    return unless quote&.validated? && !quote.validated_at_changed?
    errors.add(:base, "cannot modify items of a validated quote")
  end

  def prevent_destroy_if_quote_validated
    throw(:abort) if quote&.validated?
  end
end
