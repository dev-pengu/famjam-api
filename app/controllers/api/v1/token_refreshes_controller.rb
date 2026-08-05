module Api
  module V1
    class TokenRefreshesController < ApplicationController
      skip_before_action :authenticate_user!

      def create
        contract = TokenRefreshParams.build(params)
        return render_invalid(contract) unless contract.valid?

        result = RefreshTokenService.call(
          raw_refresh_token: contract.refresh_token,
          device_name: contract.device_name,
          user_agent: request.user_agent,
          ip_address: request.remote_ip,
        )
        return render json: { errors: result.errors }, status: :unauthorized if result.failure?

        render json: result.data, status: :created
      end
    end
  end
end
