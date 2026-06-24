class RewardMailer < ApplicationMailer
  default from: ENV.fetch("MAIL_FROM", "no-reply@fideli.app")

  def reward_available
    @reward = params[:reward]
    @customer = @reward.customer
    @barbershop = @reward.barbershop
    @portal_url = params[:portal_url] || "#{ENV.fetch("APP_URL", "http://localhost:3000")}/cliente/login"

    mail(
      to: @customer.email,
      subject: "🎉 Você ganhou uma recompensa no Fideli!"
    )
  end
end
