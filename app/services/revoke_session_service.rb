# Revokes a single device/session. Controller must authorize via
# RefreshTokenPolicy#revoke? before calling this - the service itself does
# not check ownership.
class RevokeSessionService < ApplicationService
  def initialize(refresh_token:)
    @refresh_token = refresh_token
  end

  def call
    @refresh_token.revoke!
    AuditLogger.log(
      action: "session.revoked",
      actor_user: @refresh_token.user,
      target: @refresh_token,
      metadata: { device_name: @refresh_token.device_name },
    )
    ServiceResult.success(@refresh_token)
  end
end
