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

        result = InvitationCreationService.call(actor: current_user, family: @family, **contract.to_service_args)
        render_result(result, status: :created, serializer: InvitationSerializer)
      end

      def destroy
        invitation = @family.invitations.find(params[:id])
        authorize invitation, :revoke?
        result = InvitationRevocationService.call(actor: current_user, invitation: invitation)
        render_result(result)
      end

      private

      def set_family
        @family = current_user.families.find(params[:family_id])
      end
    end
  end
end
