# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def confirmation_email(user, token)
    @user = user
    @confirmation_url = "#{ENV.fetch('APP_FRONTEND_URL', 'http://localhost:5173')}/confirm-email?token=#{token}"
    mail(to: user.email, subject: "Confirme seu email — Arkheion")
  end

  def reset_password_email(user, token)
    @user = user
    @reset_url = "#{ENV.fetch('APP_FRONTEND_URL', 'http://localhost:5173')}/reset-password?token=#{token}"
    mail(to: user.email, subject: "Redefinição de senha — Arkheion")
  end
end
