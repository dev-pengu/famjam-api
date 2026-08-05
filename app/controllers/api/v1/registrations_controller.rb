module Api
  module V1
    class RegistrationsController < ApplicationController
      skip_before_action :authenticate_user!

      def create
        contract = RegistrationParams.build(params)
        return render_invalid(contract) unless contract.valid?

        result = PasswordSignupService.call(**contract.to_service_args)
        render_result(result, status: :created, serializer: UserSerializer)
      end
    end
  end
end
