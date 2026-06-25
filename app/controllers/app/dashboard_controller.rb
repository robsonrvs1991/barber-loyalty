class App::DashboardController < ApplicationController
  before_action :require_login
  before_action :require_barber
  before_action :require_active_subscription

  def index
    @barbershop = current_barbershop
    @subscription = current_company&.subscription
    @loyalty_program = @barbershop.loyalty_program

    @customers_count = @barbershop.respond_to?(:customers) ? @barbershop.customers.count : 0
    @appointments_count = @barbershop.appointments.count
    @rewards_count = @barbershop.rewards.count
    @available_rewards_count = @barbershop.rewards.where(used: false).count
    @used_rewards_count = @barbershop.rewards.where(used: true).count

    @latest_appointments = @barbershop.appointments
                                      .includes(:customer, :service)
                                      .order(created_at: :desc)
                                      .limit(5)

    @latest_rewards = @barbershop.rewards
                                 .includes(:customer)
                                 .where(used: false)
                                 .order(created_at: :desc)
                                 .limit(5)
  end
end