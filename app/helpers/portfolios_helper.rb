module PortfoliosHelper
  def percent(value)
    number_to_percentage(value, precision: 2, strip_insignificant_zeros: true)
  end

  def trade_label(value)
    return "Hold" if value.zero?

    "#{value.positive? ? 'Buy' : 'Sell'} #{number_to_currency(value.abs)}"
  end

  def drift_label(value)
    "#{value.positive? ? '+' : ''}#{number_with_precision(value, precision: 2)} pp"
  end
end
