class ClientPortalController < ApplicationController
  skip_before_action :require_barber, raise: false
  before_action :require_client_login

  def index
    @customer = current_client
    @barbershop = @customer.barbershop
    @loyalty_program = @barbershop.loyalty_program
    @appointments = Appointment.where(customer_id: @customer.id).order(created_at: :desc)
    @rewards = Reward.where(customer_id: @customer.id).order(created_at: :desc)

    required = @loyalty_program&.required_visits.to_i
    @required_visits = required.positive? ? required : 10
    @points = @customer.loyalty_points.to_i
    @progress_percent = [[(@points.to_f / @required_visits * 100).round, 100].min, 0].max
    @remaining = [@required_visits - @points, 0].max
  end

  private

  def current_client
    @current_client ||= User.find_by(id: session[:client_user_id], role: "customer")
  end

  def require_client_login
    redirect_to client_login_path, alert: "Entre para acessar seu cartão fidelidade." unless current_client
  end
end
