Rails.application.routes.draw do
  get "landing/index"
  root "landing#index"

  get    "/login",  to: "sessions#new",     as: :login
  post   "/login",  to: "sessions#create"
  delete "/logout", to: "sessions#destroy", as: :logout

  get   "/esqueci-senha",          to: "password_resets#new",    as: :new_password_reset
  post  "/esqueci-senha",          to: "password_resets#create", as: :password_resets
  get   "/redefinir-senha/:token", to: "password_resets#edit",   as: :edit_password_reset
  patch "/redefinir-senha/:token", to: "password_resets#update", as: :password_reset

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

  resources :customers do
    member do
      patch :update_password
    end
  end

  resources :services
  resources :loyalty_programs

  get "/loyalty_program", to: redirect("/loyalty_programs")

  resources :appointments, only: [:index, :new, :create, :show]
  resources :rewards, only: [:index, :show, :update]

  get "up" => "rails/health#show", as: :rails_health_check
end