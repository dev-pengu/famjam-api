module Api
  module V1
    class RewardRedemptionsController < ApplicationController
      before_action :set_family
      before_action :set_reward_redemption, only: %i[approve deny cancel]

      def index
        authorize Reward.new(family: @family), :index?, policy_class: RewardPolicy
        redemptions = @family.reward_redemptions.includes(:reward, claimee: :person)
        redemptions = redemptions.where(status: params[:status]) if RewardRedemption.statuses.key?(params[:status])
        render json: RewardRedemptionSerializer.new(redemptions.order(created_at: :desc))
      end

      def approve
        authorize @reward_redemption, :approve?
        result = ApproveRewardRedemptionService.call(actor: current_user, reward_redemption: @reward_redemption)
        render_result(result, serializer: RewardRedemptionSerializer)
      end

      def deny
        authorize @reward_redemption, :deny?
        contract = RewardRedemptionDenyParams.build(params)
        return render_invalid(contract) unless contract.valid?

        return render_invalid(@reward_redemption) unless @reward_redemption.deny(
          reviewed_by_user: current_user, reason: contract.reason,
        )

        render json: RewardRedemptionSerializer.new(@reward_redemption)
      end

      def cancel
        authorize @reward_redemption, :cancel?
        return render_invalid(@reward_redemption) unless @reward_redemption.cancel

        render json: RewardRedemptionSerializer.new(@reward_redemption)
      end

      private

      def set_family
        @family = current_user.families.find(params[:family_id])
      end

      def set_reward_redemption
        @reward_redemption = RewardRedemption.joins(:reward).where(rewards: { family_id: @family.id }).find(params[:id])
      end
    end
  end
end
