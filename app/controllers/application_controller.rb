class ApplicationController < ActionController::Base
  helper_method :current_user,
                :current_barbershop,
                :current_company,
                :current_client,
                :logged_in?,
                :client_logged_in?,
                :owner?,
                :business?,
                :barber?,
                :customer?

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def current_client
    @current_client ||= User.find_by(id: session[:client_user_id]) if session[:client_user_id]
  end

  def current_company
    return nil unless current_user

    @current_company ||= Company.find_by(id: current_user.barbershop_id)
  end

  def current_barbershop
    current_company
  end

  def logged_in?
    current_user.present?
  end

  def client_logged_in?
    current_client.present?
  end

  def owner?
    current_user&.role == "owner"
  end

  def business?
    current_user&.role.in?(["business", "barber"])
  end

  def barber?
    business?
  end

  def customer?
    current_user&.role == "customer"
  end

  def require_login
    redirect_to login_path, alert: "Faça login para continuar." unless logged_in?
  end

  def require_owner
    redirect_to login_path, alert: "Acesso restrito ao administrador da Loy." unless owner?
  end

  def require_barber
    redirect_to root_path, alert: "Acesso restrito ao responsável da empresa." unless business?
  end

  def require_customer
    redirect_to client_login_path, alert: "Acesso restrito ao cliente." unless customer?
  end

  def require_active_subscription
    return if owner?
    return unless business?

    subscription = current_company&.subscription
    return if subscription.blank? || subscription.active?

    redirect_to subscription_blocked_path,
                alert: "Assinatura suspensa. Entre em contato com a Loy para reativar o acesso."
  end
end