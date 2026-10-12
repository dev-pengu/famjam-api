class Family < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :people, through: :memberships
  has_many :invitations, dependent: :destroy
  has_many :guardianships, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :agenda_subscriptions, dependent: :destroy
  has_many :chores, dependent: :destroy
  has_many :chore_completions, through: :chores
  has_many :rewards, dependent: :destroy
  has_many :reward_redemptions, through: :rewards

  validates :name, presence: true

  DEFAULT_INVITATION_TTL_HOURS = 72
  DEFAULT_TIMEZONE = "UTC"

  def owner_membership
    memberships.active.find_by(role: :owner)
  end

  def invitation_ttl
    (invitation_ttl_hours || DEFAULT_INVITATION_TTL_HOURS).hours
  end

  def timezone
    default_timezone.presence || DEFAULT_TIMEZONE
  end

  def add_guardian(actor:, dependent_person:, guardian_user:)
    guardianship = guardianships.create!(
      guardian_user: guardian_user, dependent_person: dependent_person, created_by_user: actor,
    )
    AuditLogger.log(
      action: "guardianship.added",
      actor_user: actor,
      family: self,
      target: guardianship,
      metadata: { guardian_user_id: guardian_user.id, dependent_person_id: dependent_person.id },
    )
    ServiceResult.success(guardianship)
  rescue ActiveRecord::RecordInvalid => e
    ServiceResult.failure(e.record.errors.full_messages)
  end

  def create_invitation(actor:, role:, email: nil, ttl_hours: nil)
    invitation = invitations.create!(
      role: role,
      created_by_user: actor,
      email: email,
      expires_at: ttl_hours ? ttl_hours.hours.from_now : nil,
    )
    ServiceResult.success(invitation)
  rescue ActiveRecord::RecordInvalid => e
    ServiceResult.failure(e.record.errors.full_messages)
  end
end
