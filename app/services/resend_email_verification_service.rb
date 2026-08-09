class ResendEmailVerificationService < ApplicationService
  def initialize(user:)
    @user = user
  end

  def call
    return ServiceResult.failure([ "email is already verified" ]) if @user.verified?

    UserMailer.verification_email(@user).deliver_later
    AuditLogger.log(action: "email.verification_resent", actor_user: @user)

    ServiceResult.success(true)
  end
end
