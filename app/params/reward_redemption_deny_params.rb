class RewardRedemptionDenyParams < ApplicationParams
  attribute :reason, :string

  validates :reason, presence: true
end
