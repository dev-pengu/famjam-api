class MembershipSetColorParams < ApplicationParams
  attribute :color, :string

  validates :color, presence: true, inclusion: { in: Membership.colors.keys }
end
