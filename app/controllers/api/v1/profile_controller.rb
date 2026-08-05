module Api
  module V1
    class ProfileController < ApplicationController
      
      def show
        render json: UserSerializer.new(current_user)
      end

      def update
        person = Person.find(params[:id])
        authorize person, :update?, policy_class: PersonPolicy

        contract = PersonUpdateParams.build(params)
        return render_invalid(contract) unless contract.valid?

        result = UpdatePersonService.call(actor: current_user, person: person, attributes: contract.to_service_args.compact)
        render_result(result, serializer: PersonSerializer)
      end
    end
  end
end