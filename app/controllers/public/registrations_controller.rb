class Public::RegistrationsController < ApplicationController
  def new
  end

  def create
    barbershop = Barbershop.create!(
      name: params[:company_name],
      phone: params[:company_phone],
      address: params[:company_address],
      whatsapp: params[:company_phone],
      active: true,
      email: params[:owner_email]
    )

    user = User.create!(
      name: params[:owner_name],
      email: params[:owner_email],
      phone: params[:owner_phone],
      password: params[:password],
      password_confirmation: params[:password_confirmation],
      role: "barber",
      barbershop: barbershop
    )

    begin
      CompanyAccessEmailService.deliver!(
        user: user,
        company: barbershop,
        login_url: "#{request.base_url}/login",
        password: params[:password]
      )
    rescue StandardError => e
      Rails.logger.error("[CompanyAccessEmailService] Falha ao enviar cadastro público: #{e.class} - #{e.message}")
    end

    session[:user_id] = user.id

    redirect_to app_dashboard_path,
                notice: "Cadastro realizado com sucesso. Bem-vindo ao Loy!"
  rescue ActiveRecord::RecordInvalid => e
    redirect_to signup_path, alert: e.record.errors.full_messages.to_sentence
  end
end