# frozen_string_literal: true

Quote.delete_all

Faker::Config.locale = :fr

vat_rates = [5.5, 10.0, 20.0]

populate_items = ->(quote) {
  rand(2..5).times do
    quote.quote_items.create!(
      name: Faker::Commerce.product_name,
      quantity: [1, 2, 3, 5, 10, 0.5, 1.5].sample,
      unit_price_cents: rand(5_000..200_000),
      vat_rate: vat_rates.sample
    )
  end
}

# 4 draft quotes
4.times do
  quote = Quote.create!(name: "Devis #{Faker::Company.name}")
  populate_items.call(quote)
end

# 2 validated quotes
2.times do
  quote = Quote.create!(name: "Devis #{Faker::Company.name}")
  populate_items.call(quote)
  quote.update!(validated_at: Faker::Time.between(from: 30.days.ago, to: 1.day.ago))
end

drafts = Quote.where(validated_at: nil).count
validated = Quote.where.not(validated_at: nil).count
puts "Seeded: #{Quote.count} quotes (#{drafts} drafts, #{validated} validated), #{QuoteItem.count} items"
