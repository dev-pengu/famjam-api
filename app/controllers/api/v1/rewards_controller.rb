module Api
  module V1
    class RewardsController < ApplicationController
      before_action :set_family
      before_action :set_reward, only: %i[show update destroy request_redemption]

      def index
        authorize Reward.new(family: @family), :index?
        render json: RewardSerializer.new(@family.rewards.active.order(created_at: :asc))
      end

      def show
        authorize @reward
        render json: RewardSerializer.new(@reward)
      end

      def create
        authorize Reward.new(family: @family), :create?
        contract = RewardCreateParams.build(params)
        return render_invalid(contract) unless contract.valid?

        reward = @family.rewards.create(created_by_user: current_user, **contract.to_service_args)
        return render_invalid(reward) unless reward.persisted?

        render json: RewardSerializer.new(reward), status: :created
      end

      def update
        authorize @reward
        contract = RewardUpdateParams.build(params)
        return render_invalid(contract) unless contract.valid?

        return render_invalid(@reward) unless @reward.update(contract.to_service_args.compact)

        render json: RewardSerializer.new(@reward)
      end

      def destroy
        authorize @reward, :archive?
        @reward.archive
        render json: RewardSerializer.new(@reward)
      end

      def request_redemption
        contract = RewardRedemptionCreateParams.build(params)
        return render_invalid(contract) unless contract.valid?

        claimee = contract.claimee_id.present? ? @family.memberships.find(contract.claimee_id) : own_membership

        authorize @reward.reward_redemptions.new(claimee: claimee)
        redemption = @reward.request_redemption(claimee: claimee)
        return render_invalid(redemption) unless redemption.persisted?

        render json: RewardRedemptionSerializer.new(redemption), status: :created
      end

      private

      def set_family
        @family = current_user.families.find(params[:family_id])
      end

      def set_reward
        @reward = @family.rewards.find(params[:id])
      end

      def own_membership
        @family.memberships.active.find_by!(person: current_user.person)
      end
    end
  end
end
