require "test_helper"

class RebalancePreviewTest < ActiveSupport::TestCase
  def preview_for(entries)
    portfolio = Portfolio.new(name: "Example", holdings_attributes: entries.map do |symbol, value, target|
      { symbol:, market_value: value, target_percent: target }
    end)
    RebalancePreview.new(portfolio)
  end

  test "calculates allocation drift and matching buy and sell amounts" do
    preview = preview_for([ [ "STOCK", 700, 60 ], [ "BOND", 300, 40 ] ])
    stock = preview.rows.find { |row| row.holding.symbol == "STOCK" }
    assert_equal BigDecimal("70"), stock.current_percent
    assert_equal BigDecimal("10"), stock.drift
    assert_equal BigDecimal("600"), stock.target_value
    assert_equal BigDecimal("-100"), stock.trade_value
    assert_equal BigDecimal("0"), preview.rows.sum(&:trade_value)
  end

  test "a portfolio already at target produces no trades" do
    preview = preview_for([ [ "STOCK", 600, 60 ], [ "BOND", 400, 40 ] ])
    assert preview.rows.all? { |row| row.trade_value.zero? }
    assert_equal 0, preview.max_drift
  end

  test "distributes leftover pennies predictably without creating money" do
    preview = preview_for([ [ "AA", "0.01", "33.33" ], [ "BB", "0.01", "33.33" ], [ "CC", "0.03", "33.34" ] ])
    assert_equal [ BigDecimal("0.02"), BigDecimal("0.01"), BigDecimal("0.02") ], preview.rows.map(&:target_value)
    assert_equal BigDecimal("0.05"), preview.rows.sum(&:target_value)
    assert_equal 0, preview.rows.sum(&:trade_value)
  end

  test "supports moving out of a holding with a zero target" do
    preview = preview_for([ [ "STOCK", 600, 0 ], [ "BOND", 400, 100 ] ])
    assert_equal [ BigDecimal("600"), BigDecimal("-600") ], preview.rows.map(&:trade_value)
  end

  test "rejects a zero total rather than dividing by zero" do
    assert_raises(ArgumentError) { preview_for([ [ "CASH", 0, 100 ] ]) }
  end

  test "rejects incomplete targets rather than manufacturing a rebalance" do
    assert_raises(ArgumentError) { preview_for([ [ "CASH", 100, 50 ] ]) }
  end

  test "preserves total value across portfolios with fractional targets" do
    random = Random.new(42)
    25.times do
      amounts = 3.times.map { BigDecimal(random.rand(1..100_000).to_s) / 100 }
      preview = preview_for([ [ "AA", amounts[0], "29.73" ], [ "BB", amounts[1], "40.08" ], [ "CC", amounts[2], "30.19" ] ])
      assert_equal amounts.sum, preview.rows.sum(&:target_value)
      assert_equal 0, preview.rows.sum(&:trade_value)
    end
  end
end
