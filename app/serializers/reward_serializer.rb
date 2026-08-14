class RewardSerializer < ApplicationSerializer
  private

  def serialize(reward)
    {
      id: reward.id,
      family_id: reward.family_id,
      created_by_user_id: reward.created_by_user_id,
      title: reward.title,
      description: reward.description,
      coin_cost: reward.coin_cost,
      status: reward.status,
      created_at: reward.created_at
    }
  end
end
