class DashboardController < ApplicationController
  before_action :require_login

  def index
    if barber?
      @barbershop = current_user.barbershop
      @customers_count = @barbershop.customers.count
      @appointments_count = @barbershop.appointments.count
      @rewards_count = @barbershop.rewards.count
      @available_rewards_count = @barbershop.rewards.where(used: [false, nil]).count
      @recent_appointments = @barbershop.appointments.includes(:customer, :service).order(created_at: :desc).limit(5)
    else
      @barbershop = current_user.barbershop
      @program = @barbershop.loyalty_program
      @points = current_user.loyalty_points
      @target = @program&.required_visits || 10
      @remaining = [@target - (@points % @target), 0].max
      @appointments = current_user.customer_appointments.includes(:service).order(created_at: :desc).limit(10)
      @rewards = current_user.rewards.order(created_at: :desc)
    end
  end
end
