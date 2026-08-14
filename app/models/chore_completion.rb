class ChoreCompletion < ApplicationRecord
  belongs_to :chore
  belongs_to :completed_by_membership, class_name: "Membership"
  belongs_to :reviewed_by_user, class_name: "User", optional: true
  belongs_to :coin_transaction, optional: true

  enum :status, { pending_approval: 0, approved: 1, rejected: 2 }, default: :pending_approval

  validates :due_on, presence: true, uniqueness: { scope: :chore_id }
  validates :completed_at, presence: true
  validates :coin_value, presence: true, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :reviewed_by_user, :reviewed_at, presence: true, unless: :pending_approval?
  validates :coin_transaction, presence: true, if: :approved?
  validates :rejection_reason, presence: true, if: :rejected?
  validate :completed_by_membership_matches_assignee
  validate :chore_must_be_active, on: :create
  validate :status_transitions_from_pending_approval, on: :update

  before_validation :snapshot_coin_value, on: :create

  def reject(reviewed_by_user:, reason:)
    update(status: :rejected, reviewed_by_user: reviewed_by_user, reviewed_at: Time.current, rejection_reason: reason)
  end

  private

  def snapshot_coin_value
    self.coin_value ||= chore&.coin_value
  end

  def completed_by_membership_matches_assignee
    return unless chore && completed_by_membership

    errors.add(:completed_by_membership, "must be the chore's assignee") if completed_by_membership_id != chore.assignee_id
  end

  def chore_must_be_active
    errors.add(:chore, "is archived") if chore && !chore.active?
  end

  def status_transitions_from_pending_approval
    errors.add(:status, "cannot be changed once reviewed") unless status_was == "pending_approval"
  end
end
