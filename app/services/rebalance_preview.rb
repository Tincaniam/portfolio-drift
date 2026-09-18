class RebalancePreview
  Row = Data.define(:holding, :current_percent, :drift, :target_value, :trade_value)

  attr_reader :total_value, :rows

  def initialize(portfolio)
    @total_value = portfolio.total_value
    holdings = portfolio.active_holdings.sort_by(&:symbol)
    raise ArgumentError, "Portfolio value must be positive" unless total_value.positive?
    raise ArgumentError, "Targets must total 100%" unless holdings.sum(&:target_percent) == 100

    total_cents = (total_value * 100).to_i
    exact_cents = holdings.map { |holding| total_cents * holding.target_percent.to_r / 100 }
    target_cents = exact_cents.map(&:floor)

    # Give leftover cents to the largest fractional remainders so trades net to zero.
    ranked = holdings.each_index.sort_by { |i| [ -(exact_cents[i] - target_cents[i]), holdings[i].symbol ] }
    (total_cents - target_cents.sum).times { |i| target_cents[ranked[i]] += 1 }

    @rows = holdings.each_with_index.map do |holding, i|
      current = holding.market_value / total_value * 100
      target = BigDecimal(target_cents[i].to_s) / 100
      Row.new(holding:, current_percent: current, drift: current - holding.target_percent,
        target_value: target, trade_value: target - holding.market_value)
    end
  end

  def max_drift
    rows.map { |row| row.drift.abs }.max
  end
end
