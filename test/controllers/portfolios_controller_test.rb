require "test_helper"

class PortfoliosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @portfolio = Portfolio.create!(name: "Demo", holdings_attributes: [
      { symbol: "STOCK", market_value: 700, target_percent: 60 },
      { symbol: "BOND", market_value: 300, target_percent: 40 }
    ])
  end

  test "lists portfolios and displays a rebalance preview" do
    get root_path
    assert_response :success
    assert_select "h2 a", "Demo"
    get portfolio_path(@portfolio)
    assert_response :success
    assert_select ".trade.buy", "Buy $100.00"
    assert_select ".trade.sell", "Sell $100.00"
  end

  test "renders the new and edit forms" do
    get new_portfolio_path
    assert_response :success
    assert_select "form[data-controller=allocation]"
    get edit_portfolio_path(@portfolio)
    assert_response :success
    assert_select ".holding-row input[value=STOCK]"
  end

  test "preserves a browser session between page visits" do
    previous = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true
    get root_path
    assert_response :success
    assert cookies["_portfolio_drift_session"].present?
    get portfolio_path(@portfolio)
    assert_response :success
    assert_select "meta[name=csrf-token]"
  ensure
    ActionController::Base.allow_forgery_protection = previous
  end

  test "creates a portfolio and its holdings together" do
    assert_difference [ "Portfolio.count", "Holding.count" ], 1 do
      post portfolios_path, params: { portfolio: { name: "Cash reserve", holdings_attributes: {
        "0" => { symbol: "cash", market_value: 500, target_percent: 100 }
      } } }
    end
    assert_redirected_to portfolio_path(Portfolio.last)
    assert_equal "CASH", Portfolio.last.holdings.first.symbol
  end

  test "invalid creation renders errors without saving anything" do
    assert_no_difference [ "Portfolio.count", "Holding.count" ] do
      post portfolios_path, params: { portfolio: { name: "Incomplete", holdings_attributes: {
        "0" => { symbol: "CASH", market_value: 500, target_percent: 80 }
      } } }
    end
    assert_response :unprocessable_entity
    assert_select ".errors", /Target allocations must total 100%/
    assert_select "input[value=Incomplete]"
  end

  test "invalid update leaves stored holdings unchanged" do
    stock = @portfolio.holdings.find_by!(symbol: "STOCK")
    patch portfolio_path(@portfolio), params: { portfolio: { holdings_attributes: {
      "0" => { id: stock.id, target_percent: 50 }
    } } }
    assert_response :unprocessable_entity
    assert_equal 60, stock.reload.target_percent
  end

  test "updates targets and removes a holding in the same transaction" do
    stock, bond = @portfolio.holdings.order(symbol: :desc).to_a
    patch portfolio_path(@portfolio), params: { portfolio: { name: "Single holding", holdings_attributes: {
      "0" => { id: stock.id, target_percent: 100 }, "1" => { id: bond.id, _destroy: "1" }
    } } }
    assert_redirected_to portfolio_path(@portfolio)
    assert_equal 1, @portfolio.reload.holdings.count
    assert_equal 100, @portfolio.holdings.first.target_percent
  end

  test "deleting a portfolio removes its holdings" do
    assert_difference "Holding.count", -2 do
      assert_difference "Portfolio.count", -1 do
        delete portfolio_path(@portfolio)
      end
    end
    assert_redirected_to portfolios_path
  end

  test "returns not found for a missing portfolio" do
    get portfolio_path(id: -1)
    assert_response :not_found
  end
end
