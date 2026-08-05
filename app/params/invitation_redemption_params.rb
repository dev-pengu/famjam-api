class InvitationRedemptionParams < ApplicationParams
  attribute :code, :string

  validates :code, presence: true
end
