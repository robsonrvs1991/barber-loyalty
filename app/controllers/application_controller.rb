class ApplicationController < ActionController::Base
  helper_method :current_user,
                :current_barbershop,
                :current_client,
                :logged_in?,
                :client_logged_in?,
                :barber?,
                :customer?

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def current_client
    @current_client ||= User.find_by(id: session[:client_user_id]) if session[:client_user_id]
  end

  def current_barbershop
    return nil unless current_user
    @current_barbershop ||= current_user.barbershop
  end

  def logged_in?
    current_user.present?
  end

  def client_logged_in?
    current_client.present?
  end

  def barber?
    current_user&.role == "barber"
  end

  def customer?
    current_user&.role == "customer"
  end

  def require_login
    redirect_to login_path, alert: "Faça login para continuar." unless logged_in?
  end

  def require_barber
    redirect_to root_path, alert: "Acesso restrito ao barbeiro." unless barber?
  end

  def require_customer
    redirect_to cliente_login_path, alert: "Acesso restrito ao cliente." unless customer?
  end
end