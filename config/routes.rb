Rails.application.routes.draw do
  root "portfolios#index"
  resources :portfolios
  get "up" => "rails/health#show", as: :rails_health_check
end
