class VerifyEmailService < ApplicationService
  def initialize(token:)
    @token = token
  end

  def call
    user = User.find_by_token_for(:email_verification, @token)
    return ServiceResult.failure(['invalid or expired verification link']) unless user

    user.update!(email_verified_at: Time.current) unless user.verified?
    AuditLogger.log(action: 'email.verified', actor_user: user)

    ServiceResult.success(user)
  end
end