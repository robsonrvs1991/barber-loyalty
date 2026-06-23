class RewardsController < ApplicationController
  before_action :require_login
  before_action :require_barber

  def index
    @rewards = current_user.barbershop.rewards.includes(:customer).order(created_at: :desc)
  end

  def update
    @reward = current_user.barbershop.rewards.find(params[:id])
    @reward.update(used: true, used_at: Time.current)
    redirect_to rewards_path, notice: "Recompensa marcada como utilizada."
  end
end
