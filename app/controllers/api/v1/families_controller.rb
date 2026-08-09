module Api
  module V1
    class FamiliesController < ApplicationController
      before_action :require_verified_email!, only: :create
      before_action :set_family, only: %i[show update switch]

      def index
        memberships = current_user.memberships.active.includes(:family).order(joined_at: :asc)
        render json: memberships.map { |m| FamilyWithMembershipSerializer.new(m).as_json }
      end

      def show
        authorize @family, :show?
        render json: FamilySerializer.new(@family)
      end

      def create
        contract = FamilyCreateParams.build(params)
        return render_invalid(contract) unless contract.valid?

        result = FamilyCreationService.call(user: current_user, name: contract.name)
        render_result(result, status: :created, serializer: FamilySerializer)
      end

      def update
        authorize @family, :update?
        contract = FamilyUpdateParams.build(params)
        return render_invalid(contract) unless contract.valid?

        @family.update!(contract.to_service_args.compact)
        render json: FamilySerializer.new(@family)
      end

      # Convenience only - updates users.active_family_id so the next login
      # defaults here. NOT used for authorization anywhere; every
      # family-scoped request still resolves its own current_family from the
      # X-Family-Id header (see ApplicationController#current_family).
      def switch
        authorize @family, :show?
        current_user.update!(active_family: @family)
        head :no_content
      end

      private

      def set_family
        @family = current_user.families.find(params[:id])
      end
    end
  end
end
