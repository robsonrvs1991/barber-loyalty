class SessionsController < ApplicationController
  def new; end

def create
  user = User.find_by(email: params[:email].to_s.downcase)

  if user&.authenticate(params[:password])
    session[:user_id] = nil
    session[:client_user_id] = nil

    case user.role
    when "owner"
      session[:user_id] = user.id
      redirect_to owner_dashboard_path, notice: "Login realizado com sucesso."

    when "business", "barber"
      session[:user_id] = user.id
      redirect_to app_dashboard_path, notice: "Login realizado com sucesso."

    when "customer"
      session[:client_user_id] = user.id
      redirect_to client_portal_path, notice: "Login realizado com sucesso."

    else
      redirect_to login_path, alert: "Perfil de acesso inválido."
    end
  else
    flash.now[:alert] = "Email ou senha inválidos."
    render :new, status: :unprocessable_entity
  end
end

  def destroy
    session[:user_id] = nil
    redirect_to login_path, notice: "Você saiu do sistema."
  end
end