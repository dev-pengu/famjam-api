# Rotates a refresh token on every use. If the presented token was already
# revoked (i.e. it was already rotated out once before), that's a strong
# signal of token theft - every session for the user gets revoked and the
# caller must re-authenticate from scratch.
class RefreshTokenService < ApplicationService
  def initialize(raw_refresh_token:, device_name: nil, user_agent: nil, ip_address: nil)
    @raw_refresh_token = raw_refresh_token
    @device_name = device_name
    @user_agent = user_agent
    @ip_address = ip_address
  end

  def call
    token_hash = RefreshToken.hash_token(@raw_refresh_token)
    refresh_token = RefreshToken.find_by(token_hash: token_hash)
    return ServiceResult.failure(['invalid refresh token']) unless refresh_token

    if refresh_token.revoked? || refresh_token.expired?
      handle_suspected_reuse(refresh_token) if refresh_token.revoked?
      return ServiceResult.failure(['refresh token is no longer valid'])
    end

    user = refresh_token.user
    refresh_token.revoke!

    tokens = IssueTokenPairService.call(
      user: user, device_name: @device_name, user_agent: @user_agent, ip_address: @ip_address,
    )

    ServiceResult.success(tokens)
  end

  private

  def handle_suspected_reuse(refresh_token)
    user = refresh_token.user
    user.refresh_tokens.active.find_each(&:revoke!)
    AuditLogger.log(
      action: 'security.refresh_token_reuse_detected',
      actor_user: user,
      metadata: { ip_address: @ip_address },
    )
  end
end
