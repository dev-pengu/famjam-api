class Family < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :people, through: :memberships
  has_many :invitations, dependent: :destroy
  has_many :guardianships, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :agenda_subscriptions, dependent: :destroy

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
end
