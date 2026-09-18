class Holding < ApplicationRecord
  belongs_to :portfolio, inverse_of: :holdings

  normalizes :symbol, with: ->(symbol) { symbol.strip.upcase }
  validates :symbol, presence: true, format: { with: /\A[A-Z][A-Z0-9.-]{0,9}\z/ }
  validates :market_value, numericality: { greater_than_or_equal_to: 0, less_than: 1_000_000_000_000 }
  validates :target_percent, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
end
