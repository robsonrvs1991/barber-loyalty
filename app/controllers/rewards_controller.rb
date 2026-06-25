class RewardsController < ApplicationController
  before_action :require_login
  before_action :require_barber

  def index
    @code = params[:code].to_s.strip.upcase

    @rewards = current_user.barbershop
                           .rewards
                           .includes(:customer)
                           .order(created_at: :desc)

    if @code.present?
      @rewards = @rewards.where("UPPER(code) LIKE ?", "%#{@code}%")
    end
  end

  def show
    @reward = current_user.barbershop.rewards.find(params[:id])
  end

  def update
    @reward = current_user.barbershop.rewards.find(params[:id])

    if @reward.used?
      redirect_to reward_path(@reward), alert: "Esta recompensa já foi utilizada."
      return
    end

    @reward.update!(
      used: true,
      used_at: Time.current
    )

    redirect_to reward_path(@reward), notice: "Recompensa utilizada com sucesso."
  end
end