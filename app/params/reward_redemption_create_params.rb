class RewardRedemptionCreateParams < ApplicationParams
  # Optional:
  # nil = current user self redeem
  # value = guardian/admin redeeming on behalf of
  attribute :claimee_id, :string

  validates :claimee_id, format: { with: UUID_REGEXP }, allow_nil: true
end
