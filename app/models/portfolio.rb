class Portfolio < ApplicationRecord
  has_many :holdings, dependent: :destroy, inverse_of: :portfolio
  accepts_nested_attributes_for :holdings, allow_destroy: true, reject_if: :all_blank

  normalizes :name, with: ->(name) { name.strip }
  validates :name, presence: true, length: { maximum: 80 }
  validate :allocation_is_complete

  def active_holdings
    holdings.reject(&:marked_for_destruction?)
  end

  def total_value
    active_holdings.sum(BigDecimal("0")) { |holding| holding.market_value || 0 }
  end

  private

  def allocation_is_complete
    rows = active_holdings
    errors.add(:base, "Include between 1 and 12 holdings.") unless (1..12).cover?(rows.size)
    errors.add(:base, "Portfolio value must be greater than zero.") unless total_value.positive?

    total = rows.sum(BigDecimal("0")) { |holding| holding.target_percent || 0 }
    errors.add(:base, "Target allocations must total 100%.") unless total == 100
    symbols = rows.map(&:symbol).compact
    errors.add(:base, "Each holding must have a different symbol.") unless symbols.uniq.size == symbols.size
  end
end
