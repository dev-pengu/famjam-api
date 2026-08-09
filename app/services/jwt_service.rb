class JwtService
  ACCESS_TOKEN_TTL = 15.minutes

  class DecodeError < StandardError; end

  def self.encode_access_token(user_id:)
    payload = { user_id: user_id, exp: ACCESS_TOKEN_TTL.from_now.to_i, type: "access" }
    JWT.encode(payload, secret, "HS256")
  end

  def self.decode(token)
    payload = JWT.decode(token, secret, true, algorithm: "HS256").first
    payload.with_indifferent_access
  rescue JWT::DecodeError, JWT::ExpiredSignature => e
    raise DecodeError, e.message
  end

  def self.secret
    Rails.application.credentials.dig(:jwt, :secret) || ENV.fetch("JWT_SECRET")
  end
  private_class_method :secret
end
