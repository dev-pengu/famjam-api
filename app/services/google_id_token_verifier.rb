class GoogleIdTokenVerifier

  def self.verify(token)
    validator = Google::Auth::IDTokens
    aud = Rails.application.credentials.google['oauth_client_id']
    
    payload = validator.verify_oidc(token, aud: aud)

    email = payload['email']
    first_name = payload['given_name']
    last_name = payload['family_name']
    sub = payload['sub']
    email_verified = payload['email_verified']

    {email: email, first_name: first_name, last_name: last_name, sub: sub, email_verified: email_verified }
  end
end