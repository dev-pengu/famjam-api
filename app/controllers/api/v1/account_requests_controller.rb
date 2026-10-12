module Api
  module V1
    class AccountRequestsController < ApplicationController
      def index
        render json: AccountRequestSerializer.new(current_user.account_requests)
      end

      def create
        contract = AccountRequestParams.build(params)
        return render_invalid(contract) unless contract.valid?

        request_type = contract.kind == "deletion" ? :delete : :export

        result = current_user.create_account_request(request_type)
        return render_result(result) if result.failure?

        authorize result.data, :show?
        render json: AccountRequestSerializer.new(result.data), status: :created
      end
    end
  end
end
