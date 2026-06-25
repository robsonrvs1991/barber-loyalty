class Reward < ApplicationRecord
  belongs_to :barbershop
  belongs_to :customer, class_name: "User"

  before_validation :generate_code, on: :create

  validates :code, presence: true, uniqueness: true

  def self.create_if_earned!(customer, barbershop)
  loyalty_program = barbershop.loyalty_program
  return unless loyalty_program

  required_points = loyalty_program.required_visits

  total_points = barbershop.appointments.where(customer: customer).sum(:points)
  rewards_count = barbershop.rewards.where(customer: customer).count

  already_used_points = rewards_count * required_points

  return if total_points < already_used_points + required_points

  create!(
    barbershop: barbershop,
    customer: customer,
    description: loyalty_program.reward_description,
    used: false,
    earned_at: Time.current
  )
end

  private

  def generate_code
    return if code.present?

    loop do
      self.code = "LOY-#{SecureRandom.alphanumeric(6).upcase}"
      break unless Reward.exists?(code: code)
    end
  end
end