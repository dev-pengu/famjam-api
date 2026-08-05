module Api
  module V1
    class PasswordChangesController < ApplicationController
      def update
        authorize current_user, :change_password?, policy_class: UserPolicy

        contract = ChangePasswordParams.build(params)
        return render_invalid(contract) unless contract.valid?

        result = ChangePasswordService.call(
          user: current_user,
          current_password: contract.current_password,
          new_password: contract.new_password,
          device_name: contract.device_name,
          user_agent: request.user_agent,
          ip_address: request.remote_ip,
        )
        return render_result(result) if result.failure?

        # Returns a fresh token pair - the frontend must overwrite its
        # stored tokens with these, since every previous refresh token
        # (including, functionally, the one that was in use before this
        # request) has just been revoked server-side.
        render json: result.data
      end
    end
  end
end
