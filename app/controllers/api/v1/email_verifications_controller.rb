module Api
  module V1
    class EmailVerificationsController < ApplicationController
      skip_before_action :authenticate_user!, only: :create

      def create
        contract = EmailVerificationParams.build(params)
        return render_invalid(contract) unless contract.valid?

        result = VerifyEmailService.call(token: contract.token)
        return render_result(result) if result.failure?

        render json: { message: 'email verified' }
      end

      def resend
        authorize current_user, :resend_verification?
        result = ResendEmailVerificationService.call(user: current_user)
        render_result(result)
      end
    end
  end
end
