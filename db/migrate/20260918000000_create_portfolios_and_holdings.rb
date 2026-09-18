class CreatePortfoliosAndHoldings < ActiveRecord::Migration[8.1]
  def change
    create_table :portfolios do |t|
      t.string :name, null: false
      t.timestamps
    end

    create_table :holdings do |t|
      t.references :portfolio, null: false, foreign_key: true
      t.string :symbol, null: false
      t.decimal :market_value, precision: 14, scale: 2, null: false
      t.decimal :target_percent, precision: 5, scale: 2, null: false
      t.timestamps
    end

    add_check_constraint :holdings, "market_value >= 0", name: "nonnegative_market_value"
    add_check_constraint :holdings, "target_percent BETWEEN 0 AND 100", name: "valid_target_percent"
  end
end
