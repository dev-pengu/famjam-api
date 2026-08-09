module Api
  module V1
    class MembershipsController < ApplicationController
      before_action :set_family

      ROSTER_INCLUDES = { person: { guardians: :person } }.freeze

      def index
        authorize Membership.new(family: @family), :index?
        render json: MembershipSerializer.new(@family.memberships.active.includes(ROSTER_INCLUDES))
      end

      def destroy
        membership = @family.memberships.find(params[:id])
        authorize membership, :remove?
        result = MemberRemovalService.call(actor: current_user, membership: membership)
        render_result(result, serializer: MembershipSerializer)
      end

      def leave
        membership = @family.memberships.active.find_by!(person: current_user.person)
        authorize membership, :leave?
        result = MemberLeaveService.call(membership: membership)
        render_result(result, serializer: MembershipSerializer)
      end

      def grant_admin
        membership = @family.memberships.find(params[:id])
        authorize membership, :grant_admin?
        result = AdminGrantService.call(actor: current_user, membership: membership)
        render_result(result, serializer: MembershipSerializer)
      end

      def revoke_admin
        membership = @family.memberships.find(params[:id])
        authorize membership, :revoke_admin?
        result = AdminRevocationService.call(actor: current_user, membership: membership)
        render_result(result, serializer: MembershipSerializer)
      end

      def transfer_ownership
        new_owner_membership = @family.memberships.find(params[:id])
        authorize new_owner_membership, :transfer_ownership?

        result = OwnershipTransferService.call(
          current_owner_membership: @family.owner_membership,
          new_owner_membership: new_owner_membership,
        )
        render_result(result, serializer: MembershipSerializer)
      end

      def age_up
        membership = @family.memberships.find(params[:id])
        authorize membership, :age_up?
        result = AgeUpService.call(actor: current_user, membership: membership)
        render_result(result, serializer: MembershipSerializer)
      end

      def former
        authorize Membership.new(family: @family), :view_former?
        render json: MembershipSerializer.new(@family.memberships.inactive.includes(ROSTER_INCLUDES))
      end

      def set_color
        membership = @family.memberships.find(params[:id])
        authorize membership, :set_color?

        contract = MembershipSetColorParams.build(params)
        return render_invalid(contract) unless contract.valid?

        result = SetMembershipColorService.call(actor: current_user, membership: membership, color: contract.color)
        render_result(result, serializer: MembershipSerializer)
      end

      def reactivate
        membership = @family.memberships.find(params[:id])
        authorize membership, :reactivate?
 
        contract = ReactivateMembershipParams.build(params)
        return render_invalid(contract) unless contract.valid?
 
        result = ReactivateMembershipService.call(actor: current_user, membership: membership, role: contract.role)
        render_result(result, serializer: MembershipSerializer)
      end

      private

      def set_family
        @family = current_user.families.find(params[:family_id])
      end
    end
  end
end
