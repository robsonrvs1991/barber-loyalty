class LoyaltyProgram < ApplicationRecord
  belongs_to :barbershop

  validates :required_visits, numericality: { only_integer: true, greater_than: 0 }
  validates :reward_description, presence: true
end
