class LoginService < ApplicationService
  def initialize(email:, password:, device_name: nil, user_agent: nil, ip_address: nil)
    @email = email
    @password = password
    @device_name = device_name
    @user_agent = user_agent
    @ip_address = ip_address
  end

  def call
    user = User.active.find_by(email: @email)
    return ServiceResult.failure([ "invalid email or password" ]) unless user

    if user.locked?
      AuditLogger.log(action: "login.blocked_locked", actor_user: user)
      return ServiceResult.failure([ "account is temporarily locked, try again later" ])
    end

    unless user.authenticate(@password)
      user.register_failed_login!
      AuditLogger.log(
        action: user.locked? ? "login.locked" : "login.failed",
        actor_user: user,
        metadata: { ip_address: @ip_address },
      )
      return ServiceResult.failure([ "invalid email or password" ])
    end

    user.reset_lockout!
    user.update!(last_login_at: Time.current)

    tokens = IssueTokenPairService.call(
      user: user, device_name: @device_name, user_agent: @user_agent, ip_address: @ip_address,
    )

    AuditLogger.log(action: "login.success", actor_user: user, metadata: { ip_address: @ip_address })
    ServiceResult.success(tokens)
  end
end
