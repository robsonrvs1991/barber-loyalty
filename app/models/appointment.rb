class Appointment < ApplicationRecord
  belongs_to :barbershop
  belongs_to :customer, class_name: "User"
  belongs_to :barber, class_name: "User", optional: true
  belongs_to :service

  validates :points, numericality: { greater_than_or_equal_to: 0 }
end
