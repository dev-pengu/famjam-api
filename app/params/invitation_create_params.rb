class InvitationCreateParams < ApplicationParams
  attribute :role, :string
  attribute :email, :string
  attribute :ttl_hours, :integer

  # Deliberately excludes "owner" - invites can never grant ownership
  ALLOWED_ROLES = %w[admin adult child].freeze

  validates :role, presence: true, inclusion: { in: ALLOWED_ROLES }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :ttl_hours, numericality: { greater_than: 0, less_than_or_equal_to: 24 * 30 }, allow_nil: true
end
