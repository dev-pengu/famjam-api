module Api
  module V1
    class GuardianshipsController < ApplicationController
      before_action :set_family

      def create
        contract = GuardianshipCreateParams.build(params)
        return render_invalid(contract) unless contract.valid?

        dependent_person = Person.find(contract.dependent_person_id)
        guardian_user = User.active.find(contract.guardian_user_id)

        authorize @family.guardianships.new(dependent_person: dependent_person, guardian_user: guardian_user), :create?

        result = @family.add_guardian(
          actor: current_user, dependent_person: dependent_person, guardian_user: guardian_user,
        )
        render_result(result, status: :created, serializer: GuardianshipSerializer)
      end

      def destroy
        guardianship = @family.guardianships.find(params[:id])
        authorize guardianship, :destroy?

        result = RemoveGuardianService.call(actor: current_user, guardianship: guardianship)
        render_result(result)
      end

      private

      def set_family
        @family = current_user.families.find(params[:family_id])
      end
    end
  end
end
