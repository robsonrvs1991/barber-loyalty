module Owner
  class DashboardController < BaseController
    def index
      @companies_count = Company.count
      @subscriptions = Subscription.includes(:company)

      @active_subscriptions_count = @subscriptions.select(&:active?).count
      @blocked_subscriptions_count = @subscriptions.select(&:blocked?).count
      @free_subscriptions_count = @subscriptions.select(&:free?).count

      @customers_count = User.where(role: "customer").count
      @appointments_count = Appointment.count
      @rewards_count = Reward.count
      @used_rewards_count = Reward.where(used: true).count

      @mrr = @subscriptions.reject(&:blocked?)
                           .reject(&:free?)
                           .sum { |subscription| subscription.price.to_f }

      @arr = @mrr * 12

      @companies = Company.includes(:subscription, :users)
                          .order(created_at: :desc)
                          .limit(10)

      @recent_rewards = Reward.includes(:barbershop, :customer)
                              .order(created_at: :desc)
                              .limit(5)
    end
  end
end