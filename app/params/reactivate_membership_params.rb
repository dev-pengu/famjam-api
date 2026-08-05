class ReactivateMembershipParams < ApplicationParams
  attribute :role, :string
 
  # Never 'owner' - same reasoning as InvitationCreateParams. Omitted
  # entirely means "keep whatever role this person held before".
  validates :role, inclusion: { in: %w[admin adult child] }, allow_nil: true
end
 