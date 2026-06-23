class Service < ApplicationRecord
  belongs_to :barbershop
  has_many :appointments, dependent: :restrict_with_error

  validates :name, presence: true
  validates :points, numericality: { greater_than_or_equal_to: 0 }
end
