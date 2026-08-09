class Invitation < ApplicationRecord
  belongs_to :family
  belongs_to :created_by_user, class_name: "User"
  belongs_to :used_by_person, class_name: "Person", optional: true

  # excludes 0 to prevent inviting an owner
  enum :role, { admin: 1, adult: 2, child: 3 }

  before_validation :generate_code, on: :create
  before_validation :set_default_expiry, on: :create

  validates :code, presence: true, uniqueness: true
  validates :expires_at, presence: true

  scope :redeemable, -> { where(revoked_at: nil, used_at: nil).where("expires_at > ?", Time.current) }

  def expired?
    expires_at <= Time.current
  end

  def redeemable?
    revoked_at.nil? && used_at.nil? && !expired?
  end

  def revoke!
    update!(revoked_at: Time.current)
  end

  def redeem!(person:, redeemer_email: nil)
    raise "invitation is not redeemable" unless redeemable?
    raise "invitation is restricted to a different email" if email.present? && email.casecmp(redeemer_email.to_s).nonzero?

    transaction do
      existing_membership = family.memberships.find_by(person_id: person.id)
      raise "already an active member of this family" if existing_membership&.active?

      if existing_membership
        existing_membership.reactivate!(role: role, invited_by_user: created_by_user)
      else
        family.memberships.create!(person: person, role: role, invited_by_user: created_by_user, joined_at: Time.current)
      end

      update!(used_at: Time.current, used_by_person: person)
    end
  end

  private

    def generate_code
      self.code ||= SecureRandom.alphanumeric(12)
    end

    def set_default_expiry
      self.expires_at ||= Time.current + family.invitation_ttl
    end
end
