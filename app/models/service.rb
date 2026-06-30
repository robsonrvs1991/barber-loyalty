class Service < ApplicationRecord
  belongs_to :barbershop

  has_many :appointments, dependent: :restrict_with_error
  has_many :loyalty_programs, dependent: :restrict_with_error

  validates :name, presence: true
  validates :points,
            numericality: { greater_than_or_equal_to: 0 }

  validates :price,
            numericality: { greater_than_or_equal_to: 0 }

  scope :active, -> { where(active: true) }
end