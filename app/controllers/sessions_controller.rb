class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by(email: params[:email].to_s.downcase)

    if user&.authenticate(params[:password])
      session[:client_user_id] = nil
      session[:user_id] = user.id

      if user.role == "owner"
        redirect_to owner_dashboard_path, notice: "Login realizado com sucesso."
      else
        redirect_to root_path, notice: "Login realizado com sucesso."
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
