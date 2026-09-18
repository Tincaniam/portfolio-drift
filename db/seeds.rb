# All symbols and values are fictional. Existing portfolios are left untouched.
examples = {
  "Long-term savings" => [ [ "USSTK", 58_000, 50 ], [ "INTL", 17_000, 20 ], [ "BONDS", 20_000, 25 ], [ "CASH", 5_000, 5 ] ],
  "Balanced portfolio" => [ [ "USSTK", 30_000, 40 ], [ "INTL", 15_000, 20 ], [ "BONDS", 26_250, 35 ], [ "CASH", 3_750, 5 ] ]
}

examples.each do |name, holdings|
  next if Portfolio.exists?(name: name)

  Portfolio.create!(name: name, holdings_attributes: holdings.map do |symbol, market_value, target_percent|
    { symbol:, market_value:, target_percent: }
  end)
end
