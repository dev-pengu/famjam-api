class RequestPasswordResetService < ApplicationService
  def initialize(email:)
    @email = email
  end

  def call
    user = User.active.find_by(email: @email)

    if user
      UserMailer.password_reset_email(user).deliver_later
      AuditLogger.log(action: "password_reset.requested", actor_user: user)
    end

    ServiceResult.success(true)
  end
end
