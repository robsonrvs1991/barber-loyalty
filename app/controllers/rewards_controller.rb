class RewardsController < ApplicationController
  before_action :require_login
  before_action :require_barber

  def index
    @code = params[:code].to_s.strip.upcase

    @page = params[:page].to_i
    @page = 1 if @page < 1

    @per_page = 10

    rewards_scope = current_user.barbershop
                                .rewards
                                .includes(:customer)
                                .order(created_at: :desc)

    if @code.present?
      rewards_scope = rewards_scope.where("UPPER(code) LIKE ?", "%#{@code}%")
    end

    @total_rewards = rewards_scope.count
    @used_rewards_count = rewards_scope.where(used: true).count
    @available_rewards_count = rewards_scope.where(used: false).count

    @total_pages = (@total_rewards.to_f / @per_page).ceil
    @total_pages = 1 if @total_pages < 1

    @page = @total_pages if @page > @total_pages

    @rewards = rewards_scope
               .offset((@page - 1) * @per_page)
               .limit(@per_page)
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