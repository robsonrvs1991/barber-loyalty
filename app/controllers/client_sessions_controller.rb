class ClientSessionsController < ApplicationController
  skip_before_action :require_barber, only: [:new, :create], raise: false

  def new; end

  def create
    user = User.find_by(email: params[:email]&.downcase, role: "customer")

    if user&.authenticate(params[:password])
      session[:client_user_id] = user.id
      redirect_to client_portal_path, notice: "Login realizado com sucesso."
    else
      flash.now[:alert] = "E-mail ou senha inválidos."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:client_user_id] = nil
    redirect_to client_login_path, notice: "Você saiu da área do cliente."
  end
end
