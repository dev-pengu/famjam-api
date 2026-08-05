class ResetPasswordService < ApplicationService
  def initialize(token:, new_password:)
    @token = token
    @new_password = new_password
  end

  def call
    user = User.find_by_token_for(:password_reset, @token)
    return ServiceResult.failure(['invalid or expired reset link']) unless user

    ActiveRecord::Base.transaction do
      user.update!(password: @new_password)
      user.reset_lockout!
      user.refresh_tokens.active.find_each(&:revoke!)
    end

    AuditLogger.log(action: 'password_reset.completed', actor_user: user)
    ServiceResult.success(user)
  rescue ActiveRecord::RecordInvalid => e
    ServiceResult.failure(e.record.errors.full_messages)
  end
end
