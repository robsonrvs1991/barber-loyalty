Rails.application.routes.draw do
  get "landing/index"
  root "landing#index"

  get    "/login",  to: "sessions#new",     as: :login
  post   "/login",  to: "sessions#create"
  delete "/logout", to: "sessions#destroy", as: :logout

  get    "/cliente/login",  to: "client_sessions#new",     as: :client_login
  post   "/cliente/login",  to: "client_sessions#create"
  delete "/cliente/logout", to: "client_sessions#destroy", as: :client_logout
  get    "/cliente",        to: "client_portal#index",     as: :client_portal

  get "/assinatura/bloqueada", to: "subscriptions#blocked", as: :subscription_blocked

  namespace :public do
    resource :registration, only: [:new, :create]
  end

  get "cadastre-se", to: "public/registrations#new", as: :signup

  namespace :app do
    get "/", to: "dashboard#index", as: :dashboard
  end

  namespace :owner do
    get "/", to: "dashboard#index", as: :dashboard

    resources :companies do
      member do
        patch :reset_owner_password
      end
    end
  end

  resource :barbershop, only: [:show, :edit, :update]
  resources :customers
  resources :services
  resource :loyalty_program, only: [:show, :edit, :update]
  resources :appointments, only: [:index, :new, :create, :show]
  resources :rewards, only: [:index, :show, :update]

  get "up" => "rails/health#show", as: :rails_health_check
end