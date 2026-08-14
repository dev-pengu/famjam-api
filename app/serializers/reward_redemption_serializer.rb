class RewardRedemptionSerializer < ApplicationSerializer
  private

  def serialize(reward_redemption)
    {
      id: reward_redemption.id,
      reward_id: reward_redemption.reward_id,
      claimee_id: reward_redemption.claimee_id,
      claimee: PersonSerializer.new(reward_redemption.claimee.person).as_json,
      coin_cost: reward_redemption.coin_cost,
      status: reward_redemption.status,
      requested_at: reward_redemption.requested_at,
      reviewed_by_user_id: reward_redemption.reviewed_by_user_id,
      reviewed_at: reward_redemption.reviewed_at,
      denial_reason: reward_redemption.denial_reason,
      coin_transaction_id: reward_redemption.coin_transaction_id,
      created_at: reward_redemption.created_at
    }
  end
end
