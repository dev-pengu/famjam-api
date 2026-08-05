class RevokeAllSessionsService < ApplicationService
  def initialize(user:)
    @user = user
  end

  def call
    count = 0
    @user.refresh_tokens.active.find_each do |token|
      token.revoke!
      count += 1
    end

    AuditLogger.log(action: 'session.revoked_all', actor_user: @user, metadata: { count: count })
    ServiceResult.success(count)
  end
end
