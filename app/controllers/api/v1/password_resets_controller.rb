module Api
  module V1
    class PasswordResetsController < ApplicationController
      skip_before_action :authenticate_user!


      def create
        contract = PasswordResetRequestParams.build(params)
        return render_invalid(contract) unless contract.valid?

        RequestPasswordResetService.call(email: contract.email)
        render json: { message: "if that email is registered, a reset link has been sent" }
      end

      def update
        contract = PasswordResetConfirmParams.build(params)
        return render_invalid(contract) unless contract.valid?

        result = ResetPasswordService.call(token: contract.token, new_password: contract.password)
        return render_result(result) if result.failure?

        render json: { message: "password updated - please log in again" }
      end
    end
  end
end
