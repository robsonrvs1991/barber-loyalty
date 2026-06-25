class Subscription < ApplicationRecord
  belongs_to :company, class_name: "Company", foreign_key: :barbershop_id
  belongs_to :barbershop, optional: true

  STATUSES = %w[trial active overdue blocked canceled free].freeze

  validates :plan, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :price, numericality: { greater_than_or_equal_to: 0 }

  before_validation :set_defaults, on: :create

  def active?
    return false if blocked?
    return true if free?
    return true if status == "active"
    return true if status == "free"
    return true if status == "trial" && trial_until.present? && trial_until >= Time.current
    return true if expires_at.present? && expires_at >= Time.current

    false
  end

  def status_label
    return "Free" if free?
    return "Bloqueado" if blocked?
    return "Trial" if status == "trial"
    return "Ativo" if active?
    return "Vencido" if status == "overdue"
    return "Cancelado" if status == "canceled"

    status.to_s.humanize
  end

  private

  def set_defaults
    self.plan = "monthly" if plan.blank?
    self.price = 19.90 if price.blank?
    self.status = "trial" if status.blank?
    self.trial_until ||= 30.days.from_now if status == "trial" && !free?
    self.started_at ||= Time.current
  end
end
