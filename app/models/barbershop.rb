class Barbershop < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :services, dependent: :destroy
  has_one :loyalty_program, dependent: :destroy
  has_many :appointments, dependent: :destroy
  has_many :rewards, dependent: :destroy

  validates :name, presence: true

  def customers
    users.where(role: "customer")
  end

  def barbers
    users.where(role: "barber")
  end
end
