module Api
  module V1
    class AccountRequestsController < ApplicationController
      def index
        render json: AccountRequestSerializer.new(current_user.account_requests)
      end

      def create
        contract = AccountRequestParams.build(params)
        return render_invalid(contract) unless contract.valid?

        service = contract.kind == "deletion" ? CreateAccountDeletionRequestService : CreateDataExportRequestService
        result = service.call(user: current_user)
        return render_result(result) if result.failure?

        authorize result.data, :show?
        render json: AccountRequestSerializer.new(result.data), status: :created
      end
    end
  end
end
