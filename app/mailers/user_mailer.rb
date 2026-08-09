class UserMailer < ApplicationMailer
  FRONTEND_BASE_URL = ENV.fetch("FRONTEND_BASE_URL", "http://localhost:5173")

  def verification_email(user)
    @user = user
    @person = user.person
    token = user.generate_token_for(:email_verification)
    @verification_url = "#{FRONTEND_BASE_URL}/verify-email?token=#{token}"

    mail(to: user.email, subject: "Verify your email address")
  end

  def password_reset_email(user)
    @user = user
    @person = user.person
    token = user.generate_token_for(:password_reset)
    @reset_url = "#{FRONTEND_BASE_URL}/reset-password?token=#{token}"

    mail(to: user.email, subject: "Reset your password")
  end
end
