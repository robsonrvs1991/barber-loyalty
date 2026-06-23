class Reward < ApplicationRecord
  belongs_to :barbershop
  belongs_to :customer, class_name: "User"

  validates :description, presence: true

  def self.create_if_earned!(customer, barbershop)
    program = barbershop.loyalty_program
    return unless program

    total_points = customer.loyalty_points
    deserved_rewards = total_points / program.required_visits
    existing_rewards = customer.rewards.count

    while existing_rewards < deserved_rewards
      customer.rewards.create!(
        barbershop: barbershop,
        description: program.reward_description,
        used: false,
        earned_at: Time.current
      )
      existing_rewards += 1
    end
  end
end
