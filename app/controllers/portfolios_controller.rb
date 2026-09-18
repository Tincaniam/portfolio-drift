class PortfoliosController < ApplicationController
  before_action :set_portfolio, only: %i[show edit update destroy]

  def index
    @portfolios = Portfolio.includes(:holdings).order(created_at: :desc)
  end

  def show
    @preview = RebalancePreview.new(@portfolio)
  end

  def new
    @portfolio = Portfolio.new
    @portfolio.holdings.build(target_percent: 100)
  end

  def create
    @portfolio = Portfolio.new(portfolio_params)
    if @portfolio.save
      redirect_to @portfolio, notice: "Portfolio created. Your preview is ready."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @portfolio.update(portfolio_params)
      redirect_to @portfolio, notice: "Portfolio updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @portfolio.destroy!
    redirect_to portfolios_path, notice: "Portfolio deleted.", status: :see_other
  end

  private

  def set_portfolio
    @portfolio = Portfolio.includes(:holdings).find(params[:id])
  end

  def portfolio_params
    params.expect(portfolio: [ :name, holdings_attributes: [ [ :id, :symbol, :market_value, :target_percent, :_destroy ] ] ])
  end
end
