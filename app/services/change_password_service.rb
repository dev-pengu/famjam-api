class ChangePasswordService < ApplicationService
  def initialize(user:, current_password:, new_password:, device_name: nil, user_agent: nil, ip_address: nil)
    @user = user
    @current_password = current_password
    @new_password = new_password
    @device_name = device_name
    @user_agent = user_agent
    @ip_address = ip_address
  end

  def call
    unless @user.authenticate(@current_password)
      AuditLogger.log(action: "password_change.failed", actor_user: @user, metadata: { ip_address: @ip_address })
      return ServiceResult.failure([ "current password is incorrect" ])
    end

    if @user.authenticate(@new_password)
      return ServiceResult.failure([ "new password must be different from your current password" ])
    end

    tokens = nil
    ActiveRecord::Base.transaction do
      @user.update!(password: @new_password)

      @user.refresh_tokens.active.find_each(&:revoke!)
      tokens = IssueTokenPairService.call(
        user: @user, device_name: @device_name, user_agent: @user_agent, ip_address: @ip_address,
      )
    end

    AuditLogger.log(action: "password_change.completed", actor_user: @user, metadata: { ip_address: @ip_address })
    ServiceResult.success(tokens)
  rescue ActiveRecord::RecordInvalid => e
    ServiceResult.failure(e.record.errors.full_messages)
  end
end
