class User < ApplicationRecord
  has_secure_password

  belongs_to :barbershop, optional: true

  has_many :customer_appointments,
           class_name: "Appointment",
           foreign_key: :customer_id,
           dependent: :destroy

  has_many :barber_appointments,
           class_name: "Appointment",
           foreign_key: :barber_id,
           dependent: :nullify

  has_many :rewards,
           foreign_key: :customer_id,
           dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :role, presence: true

  def barber?
    role == "barber"
  end

  def customer?
    role == "customer"
  end

  def generate_password_reset_token!
    update!(
      reset_password_token: SecureRandom.urlsafe_base64(32),
      reset_password_sent_at: Time.current
    )
  end

  def password_reset_expired?
    reset_password_sent_at.blank? || reset_password_sent_at < 2.hours.ago
  end

  def clear_password_reset_token!
    update!(
      reset_password_token: nil,
      reset_password_sent_at: nil
    )
  end

  def loyalty_points
    if has_attribute?(:loyalty_points)
      self[:loyalty_points].to_i
    else
      customer_appointments.where(paid: true).joins(:service).sum("services.points")
    end
  rescue ActiveRecord::StatementInvalid, ActiveRecord::ConfigurationError
    0
  end

  def available_rewards_count
    rewards.where(used: false).count
  rescue ActiveRecord::StatementInvalid, ActiveRecord::ConfigurationError
    0
  end
end