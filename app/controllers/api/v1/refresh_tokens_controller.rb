module Api
  module V1
    class RefreshTokensController < ApplicationController
      def index
        tokens = policy_scope(RefreshToken.active)
        render json: RefreshTokenSerializer.new(tokens)
      end

      def destroy
        token = current_user.refresh_tokens.find(params[:id])
        authorize token, :revoke?
        result = RevokeSessionService.call(refresh_token: token)
        render_result(result)
      end

      def destroy_all
        result = RevokeAllSessionsService.call(user: current_user)
        render json: { revoked_count: result.data }
      end
    end
  end
end
