class PasswordResetMailer < ApplicationMailer
  def reset_email
    @user = params[:user]
    @reset_url = params[:reset_url]

    mail(
      to: @user.email,
      subject: "Redefinição de senha - Loy"
    )
  end
end