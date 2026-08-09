class RefreshTokenSerializer < ApplicationSerializer
  private

  def serialize(token)
    {
      id: token.id,
      device_name: token.device_name,
      user_agent: token.user_agent,
      ip_address: token.ip_address,
      last_used_at: token.last_used_at,
      expires_at: token.expires_at,
      created_at: token.created_at
    }
  end
end
