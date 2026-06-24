class Reward < ApplicationRecord
  belongs_to :customer, class_name: "User"
  belongs_to :barbershop

  scope :available, -> { where(used: [false, nil]) }
  scope :used, -> { where(used: true) }

  def used?
    used == true
  end

  def self.create_if_earned!(customer, barbershop)
    loyalty_program = barbershop.loyalty_program
    return unless loyalty_program.present?

    required_points = loyalty_program.required_visits.to_i
    return if required_points <= 0

    points = customer.loyalty_points.to_i
    return if points < required_points

    earned_rewards_count = points / required_points
    existing_rewards_count = customer.rewards.where(barbershop: barbershop).count

    return if existing_rewards_count >= earned_rewards_count

    reward = create!(
      customer: customer,
      barbershop: barbershop,
      description: loyalty_program.reward_description.presence || "Recompensa disponível",
      used: false
    )

    notify_customer_if_configured(reward)

    reward
  end

  def self.notify_customer_if_configured(reward)
    return if reward.customer.email.blank?
    return if ENV["SMTP_ADDRESS"].blank?

    RewardMailer.with(
      reward: reward,
      portal_url: "#{ENV.fetch("APP_URL", "http://localhost:3000")}/cliente/login"
    ).reward_available.deliver_now
  rescue StandardError => e
    Rails.logger.error("[RewardMailer] Falha ao enviar e-mail: #{e.class} - #{e.message}")
  end
end
