class SessionsController < ApplicationController
  skip_before_action :authenticate, only: :create

  def create
    if user = User.authenticate_by(email: params[:email], password: params[:password])
      token = JwtService.encode(user_id: user.id)

      cookies.signed[:token] = {
        value: token,
        expires: 24.hours.from_now,
        domain: "localhost",
        secure: Rails.env.production?,
        httponly: true,
        samesite: :strict
      }
      render json: {user: user.as_json(only: [ :email, :first_name, :last_name, :display_name])}, status: :created
    else
      render json: { error: "That email or password is incorrect" }, status: :unauthorized
    end
  end

  def destroy
    cookies.signed[:token] = nil
  end
end
