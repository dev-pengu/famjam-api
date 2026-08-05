module Api
  module V1
    class InvitationRedemptionsController < ApplicationController
      before_action :require_verified_email!

      def create
        contract = InvitationRedemptionParams.build(params)
        return render_invalid(contract) unless contract.valid?

        result = InvitationRedemptionService.call(
          person: current_user.person,
          code: contract.code,
          redeemer_email: current_user.email,
        )
        render_result(result, status: :created)
      end
    end
  end
end
