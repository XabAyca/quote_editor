# frozen_string_literal: true

# A customer quote made of line items. Becomes immutable once `validated_at` is set.
class Quote < ApplicationRecord
  broadcasts_to ->(_) { :quotes }, inserts_by: :append

  has_many :quote_items, inverse_of: :quote, dependent: :destroy
  accepts_nested_attributes_for :quote_items, allow_destroy: true, reject_if: :all_blank

  validates :name, presence: true
  validate :prevent_updates_after_validation, on: :update

  before_destroy :prevent_destroy_if_validated

  def validated?
    validated_at.present?
  end

  def mark_as_validated!
    update!(validated_at: Time.current)
  end

  def total_excl_tax_cents
    quote_items.sum(&:total_excl_tax_cents)
  end

  def total_vat_cents
    quote_items.sum(&:total_vat_cents)
  end

  def total_incl_tax_cents
    total_excl_tax_cents + total_vat_cents
  end

  private

  def prevent_updates_after_validation
    return unless validated? && !validated_at_changed?
    errors.add(:base, :already_validated)
  end

  def prevent_destroy_if_validated
    throw(:abort) if validated?
  end
end
