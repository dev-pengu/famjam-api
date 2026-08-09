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

      # Separate from #update: that action edits a Person (self or a
      # dependent this user is allowed to manage). Timezone is a User-level
      # account preference, always self, never a dependent's - trivial
      # enough to update inline rather than via a dedicated service.
      def timezone
        contract = ProfileTimezoneUpdateParams.build(params)
        return render_invalid(contract) unless contract.valid?

        current_user.update!(timezone: contract.timezone)
        render json: UserSerializer.new(current_user)
      end
    end
  end
end
