class Membership < ApplicationRecord
  belongs_to :family
  belongs_to :person
  belongs_to :invited_by_user, class_name: 'User', optional: true

  enum :role, { owner: 0, admin: 1, adult: 2, child: 3 }
  enum :status, { active: 0, left: 1, removed: 2 }

  validates :person_id, uniqueness: { scope: :family_id }
  validate :single_active_owner_per_family, if: -> { owner? && active? }

  scope :active, -> { where(status: :active) }
  scope :inactive, -> { where.not(status: :active) }

  def leave!
    update!(status: :left, left_at: Time.current)
  end

  def remove!
    update!(status: :removed, removed_at: Time.current)
  end

  def reactivate!(role: nil, invited_by_user: nil)
    update!(
      role: role || self.role,
      status: :active,
      joined_at: Time.current,
      left_at: nil,
      removed_at: nil,
      invited_by_user: invited_by_user || self.invited_by_user
    )
  end

  private
    def single_active_owner_per_family
      return unless family

      existing = family.memberships.active.where(role: :owner).where.not(id: id)
      errors.add(:role, 'family already has an active owner') if existing.exists?
    end
end