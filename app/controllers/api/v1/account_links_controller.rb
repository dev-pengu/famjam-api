module Api
  module V1
    class AccountLinksController < ApplicationController
      skip_before_action :authenticate_user!

      # Only called after OauthSessionsController#create returns
      # linking_required with an existing user_id - client collects
      # user's password and posts it here with OAuth provider info
      def create
        contract = AccountLinkParams.build(params)
        return render_invalid(contract) unless contract.valid?

        user = User.active.find(contract.user_id)
        result = AccountLinkingService.call(
          user: user,
          password: contract.password,
          provider: 'google',
          provider_uid: contract.provider_uid,
        )
        return render_result(result) if result.failure?

        tokens = IssueTokenPairService.call(
          user: user,
          device_name: contract.device_name,
          user_agent: request.user_agent,
          ip_address: request.remote_ip,
        )
        render json: tokens, status: :created
      end
    end
  end
end