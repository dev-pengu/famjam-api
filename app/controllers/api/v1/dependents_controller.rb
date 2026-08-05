module Api
  module V1
    class DependentsController < ApplicationController
      before_action :set_family

      def create
        # Membership doesn't exist yet, so authorize against an unpersisted
        # instance carrying the attributes DependentProfilePolicy needs.
        authorize @family.memberships.new(role: :child), :create?, policy_class: DependentProfilePolicy
        contract = DependentCreateParams.build(params)
        return render_invalid(contract) unless contract.valid?

        result = CreateManagedChildService.call(actor: current_user, family: @family, **contract.to_service_args)
        render_result(result, status: :created, serializer: MembershipSerializer)
      end

      def destroy
        membership = @family.memberships.find(params[:id])
        authorize membership, :destroy?, policy_class: DependentProfilePolicy

        result = MemberRemovalService.call(actor: current_user, membership: membership)
        render_result(result)
      end

      # Converts this managed profile into a full account with its own
      # login
      def claim
        membership = @family.memberships.find(params[:id])
        authorize membership, :claim?, policy_class: DependentProfilePolicy

        contract = ClaimManagedAccountParams.build(params)
        return render_invalid(contract) unless contract.valid?

        result = ClaimManagedAccountService.call(
          actor: current_user, membership: membership, email: contract.email, password: contract.password,
        )
        return render_result(result) if result.failure?

        render json: UserSerializer.new(result.data), status: :created
      end

      private

      def set_family
        @family = current_user.families.find(params[:family_id])
      end
    end
  end
end
