class ApplicationController < ActionController::API
  include Pundit::Authorization

  before_action :authenticate_user!

  rescue_from Pundit::NotAuthorizedError, with: :render_forbidden
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from JwtService::DecodeError, with: :render_unauthorized

  attr_reader :current_user

  private

    def authenticate_user!
      token = bearer_token
      return render_unauthorized unless token

      payload = JwtService.decode(token)
      @current_user = User.active.find_by(id: payload[:user_id])
      render_unauthorized unless @current_user
    end

    def bearer_token
      request.headers['Authorization']&.split(' ')&.last
    end

    def current_family
      return @current_family if defined?(@current_family)

      family_id = request.headers['X-Family-Id'] || params[:family_id]
      @current_family = family_id ? current_user&.families&.find_by(id: family_id) : nil
    end

    def pundit_user
      PunditUserContext.new(user: current_user, family: current_family)
    end

    def require_verified_email!
      return if current_user&.verified?

      render json: { error: 'email must be verified first' }, status: :forbidden
    end

    def render_result(result, status: :ok, serializer: nil)
      if result.failure?
        render json: { errors: result.errors }, status: :unprocessable_entity
      else
        payload = serializer ? serializer.new(result.data) : result.data
        render json: payload, status: status
      end
    end

    def render_unauthorized(_e = nil)
      render json: { error: 'unauthorized' }, status: :unauthorized
    end
    
    def render_invalid(contract)
      render json: { errors: contract.errors.full_messages }, status: :unprocessable_entity
    end

    def render_forbidden(_e)
      render json: { error: 'forbidden' }, status: :forbidden
    end

    def render_not_found(_e)
      render json: { error: 'not found' }, status: :not_found
    end
end
