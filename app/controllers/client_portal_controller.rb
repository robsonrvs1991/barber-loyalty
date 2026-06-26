class ClientPortalController < ApplicationController
  skip_before_action :require_barber, raise: false
  before_action :ensure_client_logged_in

  def index
    @customer = current_client
    @company = @customer.barbershop

    @loyalty_programs = @company.loyalty_programs.active.includes(:service).order(created_at: :asc)
    @loyalty_program = @loyalty_programs.first

    @required_points = @loyalty_program&.required_visits.to_i
    @required_points = 10 if @required_points <= 0

    @points = @customer.loyalty_points.to_i
    @remaining_points = [@required_points - @points, 0].max

    @appointments = @customer.customer_appointments.includes(:service).order(created_at: :desc)
    @rewards = @customer.rewards.includes(:loyalty_program).order(created_at: :desc)
    @services = @company.services.where(active: true).order(:name)
  end

  private

  def ensure_client_logged_in
    redirect_to client_login_path, alert: "Faça login para acessar seu cartão fidelidade." unless current_client
  end
end