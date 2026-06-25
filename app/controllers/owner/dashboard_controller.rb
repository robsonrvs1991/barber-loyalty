module Owner
  class DashboardController < BaseController
    def index
      @companies_count = Company.count
      @subscriptions = Subscription.includes(:company)
      @active_subscriptions_count = @subscriptions.select(&:active?).count
      @blocked_subscriptions_count = Subscription.where(blocked: true).count
      @free_subscriptions_count = Subscription.where(free: true).count
      @companies = Company.includes(:subscription, :users).order(created_at: :desc).limit(10)
    end
  end
end
