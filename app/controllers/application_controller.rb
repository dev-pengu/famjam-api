class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods
  include ActionController::Cookies

  before_action :authenticate

  private
    def authenticate
      if user = authenticate_with_jwt
        Current.user = user
      else
        request_http_token_authentication
      end
    end

    def authenticate_with_jwt
      token = cookies.signed[:token]
      return nil unless token

      payload = JwtService.decode(token)
      User.find_by(id: payload[:user_id]) if payload
    end

    def request_http_token_authentication
      render json: { error: "Unauthorized access" }, status: :unauthorized
    end
end
