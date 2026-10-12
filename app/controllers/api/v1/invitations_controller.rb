module Api
  module V1
    class InvitationsController < ApplicationController
      before_action :set_family

      def index
        authorize @family.invitations.new, :index?
        render json: InvitationSerializer.new(@family.invitations.redeemable)
      end

      def create
        authorize @family.invitations.new, :create?
        contract = InvitationCreateParams.build(params)
        return render_invalid(contract) unless contract.valid?

        result = @family.create_invitation(actor: current_user, **contract.to_service_args)
        render_result(result, status: :created, serializer: InvitationSerializer)
      end

      def destroy
        invitation = @family.invitations.find(params[:id])
        authorize invitation, :revoke?
        render json: { errors: result.errors }, status: :unprocessable_entity unless invitation.redeemable?
        invitation.revoke!
        render json: InvitationSerializer.new(invitation), status: :ok
      end

      private

      def set_family
        @family = current_user.families.find(params[:family_id])
      end
    end
  end
end
