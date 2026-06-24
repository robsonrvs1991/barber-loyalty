class ClientPortalController < ApplicationController
  skip_before_action :require_barber, raise: false
  before_action :require_client_login

  def index
    @customer = current_client
    @barbershop = @customer.barbershop

    @loyalty_program = @barbershop.loyalty_program
    @required_points = @loyalty_program&.required_visits.to_i
    @required_points = 10 if @required_points <= 0

    @points = @customer.loyalty_points.to_i
    @remaining_points = [@required_points - @points, 0].max

    @appointments = @customer.customer_appointments.includes(:service).order(created_at: :desc)
    @rewards = @customer.rewards.order(created_at: :desc)
    @services = @barbershop.services.where(active: true).order(:name)
  end
end
