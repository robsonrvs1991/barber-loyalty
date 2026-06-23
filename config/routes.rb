Rails.application.routes.draw do
  root "dashboard#index"

  get    "/login",  to: "sessions#new",     as: :login
  post   "/login",  to: "sessions#create"
  delete "/logout", to: "sessions#destroy", as: :logout

  get    "/cliente/login",  to: "client_sessions#new",     as: :client_login
  post   "/cliente/login",  to: "client_sessions#create"
  delete "/cliente/logout", to: "client_sessions#destroy", as: :client_logout
  get    "/cliente",        to: "client_portal#index",     as: :client_portal

  resource :barbershop, only: [:show, :edit, :update]
  resources :customers
  resources :services
  resource :loyalty_program, only: [:show, :edit, :update]
  resources :appointments, only: [:index, :new, :create, :show]
  resources :rewards, only: [:index, :update]

  get "up" => "rails/health#show", as: :rails_health_check
end
