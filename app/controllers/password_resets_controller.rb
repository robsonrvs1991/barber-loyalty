class PasswordResetsController < ApplicationController
  def new
  end

  def create
    @user = User.find_by(email: params[:email].to_s.downcase)

    if @user.present?
      @user.generate_password_reset_token!

      PasswordResetMailer.with(
        user: @user,
        reset_url: edit_password_reset_url(@user.reset_password_token)
      ).reset_email.deliver_now
    end

    redirect_to login_path, notice: "Se o e-mail existir em nossa base, enviaremos as instruções para redefinir a senha."
  end

  def edit
    @user = User.find_by(reset_password_token: params[:token])

    if @user.blank? || @user.password_reset_expired?
      redirect_to new_password_reset_path, alert: "Link inválido ou expirado. Solicite uma nova recuperação de senha."
    end
  end

  def update
    @user = User.find_by(reset_password_token: params[:token])

    if @user.blank? || @user.password_reset_expired?
      redirect_to new_password_reset_path, alert: "Link inválido ou expirado. Solicite uma nova recuperação de senha."
      return
    end

    password = params[:user][:password].to_s
    password_confirmation = params[:user][:password_confirmation].to_s

    if password.blank?
      flash.now[:alert] = "Informe a nova senha."
      render :edit, status: :unprocessable_entity
      return
    end

    if password != password_confirmation
      flash.now[:alert] = "A confirmação da senha não confere."
      render :edit, status: :unprocessable_entity
      return
    end

    if password.length < 6
      flash.now[:alert] = "A senha deve ter pelo menos 6 caracteres."
      render :edit, status: :unprocessable_entity
      return
    end

    if @user.update(password: password, password_confirmation: password_confirmation)
      @user.clear_password_reset_token!

      redirect_to login_path, notice: "Senha redefinida com sucesso. Faça login com a nova senha."
    else
      flash.now[:alert] = "Não foi possível redefinir a senha."
      render :edit, status: :unprocessable_entity
    end
  end
end