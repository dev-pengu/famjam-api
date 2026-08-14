class ApproveRewardRedemptionService < ApplicationService
  def initialize(actor:, reward_redemption:)
    @actor = actor
    @reward_redemption = reward_redemption
  end

  def call
    failure = nil

    ActiveRecord::Base.transaction do
      @reward_redemption.lock!

      unless @reward_redemption.pending_approval?
        failure = [ "Reward redemption has already been reviewed" ]
        raise ActiveRecord::Rollback
      end

      redeem_result = RedeemCoinsService.call(
        actor: @actor,
        membership: @reward_redemption.claimee,
        amount: @reward_redemption.coin_cost,
        note: "Reward: #{@reward_redemption.reward.title}",
      )

      if redeem_result.failure?
        failure = redeem_result.errors
        raise ActiveRecord::Rollback
      end

      @reward_redemption.update!(
        status: :approved,
        reviewed_by_user: @actor,
        reviewed_at: Time.current,
        coin_transaction: redeem_result.data,
      )
    end

    failure ? ServiceResult.failure(failure) : ServiceResult.success(@reward_redemption)
  rescue ActiveRecord::RecordInvalid => e
    ServiceResult.failure(e.record.errors.full_messages)
  end
end
