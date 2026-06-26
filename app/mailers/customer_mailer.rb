class CustomerMailer < ApplicationMailer
  def welcome_email
    @customer = params[:customer]
    @temporary_password = params[:temporary_password]
    @company = params[:company]
    @login_url = params[:login_url]

    mail(
      to: @customer.email,
      subject: "Seu cartão fidelidade digital está disponível"
    )
  end
end