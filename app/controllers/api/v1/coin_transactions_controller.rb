module Api
  module V1
    class CoinTransactionsController < ApplicationController
      before_action :set_family
      before_action :set_membership

      def index
        authorize @membership, :index?, policy_class: CoinTransactionPolicy
        render json: CoinTransactionSerializer.new(@membership.coin_transactions.order(created_at: :desc))
      end

      private

      def set_family
        @family = current_user.families.find(params[:family_id])
      end

      def set_membership
        @membership = @family.memberships.find(params[:membership_id])
      end
    end
  end
end
