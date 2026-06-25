class Company < ApplicationRecord
  self.table_name = "barbershops"

  has_many :users, foreign_key: :barbershop_id, dependent: :destroy
  has_many :services, foreign_key: :barbershop_id, dependent: :destroy
  has_many :appointments, foreign_key: :barbershop_id, dependent: :destroy
  has_many :rewards, foreign_key: :barbershop_id, dependent: :destroy
  has_one :loyalty_program, foreign_key: :barbershop_id, dependent: :destroy
  has_one :subscription, foreign_key: :barbershop_id, dependent: :destroy

  validates :name, presence: true

  def owner_user
    users.where(role: ["business", "barber"]).order(:id).first
  end

  def subscription_active?
    subscription.blank? || subscription.active?
  end
end
