require "test_helper"

class PortfolioTest < ActiveSupport::TestCase
  def build_portfolio(weights: [ 60, 40 ], values: [ 70, 30 ], symbols: [ "STOCK", "BOND" ])
    Portfolio.new(name: "Test portfolio", holdings_attributes: symbols.each_with_index.map do |symbol, i|
      { symbol:, market_value: values[i], target_percent: weights[i] }
    end)
  end

  test "normalizes names and symbols" do
    portfolio = build_portfolio(symbols: [ " stock ", "bond" ])
    portfolio.name = "  Retirement  "
    assert portfolio.valid?
    assert_equal "Retirement", portfolio.name
    assert_equal [ "STOCK", "BOND" ], portfolio.holdings.map(&:symbol)
  end

  test "rejects targets that do not add up to 100" do
    portfolio = build_portfolio(weights: [ 60, 35 ])
    assert_not portfolio.valid?
    assert_includes portfolio.errors[:base], "Target allocations must total 100%."
  end

  test "rejects duplicate symbols within nested holdings" do
    portfolio = build_portfolio(symbols: [ "stock", "STOCK" ])
    assert_not portfolio.valid?
    assert_includes portfolio.errors[:base], "Each holding must have a different symbol."
  end

  test "rejects negative values and out of range targets" do
    assert_not build_portfolio(values: [ -1, 101 ]).valid?
    assert_not build_portfolio(weights: [ 110, -10 ]).valid?
  end

  test "rejects nonnumeric input and malformed symbols" do
    assert_not build_portfolio(values: [ "not money", 20 ]).valid?
    assert_not build_portfolio(symbols: [ "<script>", "BOND" ]).valid?
  end

  test "requires a positive portfolio value and at least one holding" do
    assert_not build_portfolio(values: [ 0, 0 ]).valid?
    assert_not Portfolio.new(name: "Empty").valid?
  end

  test "accepts zero targets and zero value individual holdings" do
    assert build_portfolio(weights: [ 100, 0 ], values: [ 100, 0 ]).valid?
  end

  test "validates the remaining holdings when removing a row" do
    portfolio = build_portfolio
    portfolio.holdings.last.mark_for_destruction
    assert_not portfolio.valid?
    portfolio.holdings.first.target_percent = 100
    assert portfolio.valid?
  end

  test "rejects more than twelve holdings" do
    portfolio = build_portfolio
    11.times { |i| portfolio.holdings.build(symbol: "EXTRA#{i}", market_value: 1, target_percent: 0) }
    assert_not portfolio.valid?
    assert_includes portfolio.errors[:base], "Include between 1 and 12 holdings."
  end
end
