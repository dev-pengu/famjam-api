module Api
  module V1
    class OauthSessionsController < ApplicationController
      skip_before_action :authenticate_user!

      # Expects the client to have already exchanged its OAuth code/credential
      # for an ID token and sent it here as params[:id_token] - the server is
      # the one that verifies it against Google, never trusting client-claimed
      # attributes like email or provider_uid directly.
      def create
        contract = OauthSessionParams.build(params)
        return render_invalid(contract) unless contract.valid?

        begin
          payload = GoogleIdTokenVerifier.verify(contract.id_token)

          result = OauthSignupOrLoginService.call(
            provider: 'google',
            provider_uid: payload[:sub],
            email: payload[:email],
            first_name: payload[:first_name],
            last_name: payload[:last_name],
            provider_email_verified: payload[:email_verified],
          )

          if result.failure? && linking_required?(result)
            return render json: { error: 'linking_required', user_id: result.errors.first[:user_id], provider_uid: payload[:sub] }, status: :conflict
          end

          return render_result(result) if result.failure?

          tokens = IssueTokenPairService.call(
            user: result.data,
            device_name: contract.device_name,
            user_agent: request.user_agent,
            ip_address: request.remote_ip,
          )
          render json: tokens, status: :created
        rescue Google::Auth::IDTokens::SignatureError => e
          return render json: { error: 'Invalid token signature', status: :unauthorized }
        rescue StandardError => e
          render json: { error: e.message, status: :unprocessable_entity }
        end
      end

      private

      def linking_required?(result)
        result.errors.first.is_a?(Hash) && result.errors.first[:code] == :linking_required
      end
    end
  end
end
