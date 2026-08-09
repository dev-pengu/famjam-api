class IssueTokenPairService < ApplicationService
  REFRESH_TOKEN_TTL = 30.days

  def initialize(user:, device_name: nil, user_agent: nil, ip_address: nil)
    @user = user
    @device_name = device_name
    @user_agent = user_agent
    @ip_address = ip_address
  end

  def call
    raw_refresh_token = SecureRandom.hex(32)

    @user.refresh_tokens.create!(
      token_hash: RefreshToken.hash_token(raw_refresh_token),
      device_name: @device_name,
      user_agent: @user_agent,
      ip_address: @ip_address,
      expires_at: REFRESH_TOKEN_TTL.from_now,
    )

    {
      access_token: JwtService.encode_access_token(user_id: @user.id),
      refresh_token: raw_refresh_token
    }
  end
end
