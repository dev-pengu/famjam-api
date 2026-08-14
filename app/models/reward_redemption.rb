class RewardRedemption < ApplicationRecord
  belongs_to :reward
  belongs_to :claimee, class_name: "Membership"
  belongs_to :reviewed_by_user, class_name: "User", optional: true
  belongs_to :coin_transaction, optional: true

  enum :status, { pending_approval: 0, approved: 1, denied: 2, cancelled: 3 }, default: :pending_approval

  validates :coin_cost, presence: true, numericality: { greater_than: 0, only_integer: true }
  validates :requested_at, presence: true
  validates :reviewed_by_user, :reviewed_at, presence: true, if: -> { approved? || denied? }
  validates :coin_transaction, presence: true, if: :approved?
  validates :denial_reason, presence: true, if: :denied?
  validate :reward_must_be_active, on: :create
  validate :sufficient_balance_at_request, on: :create
  validate :status_transitions_from_pending_approval, on: :update

  before_validation :snapshot_coin_cost, on: :create

  def deny(reviewed_by_user:, reason:)
    update(status: :denied, reviewed_by_user: reviewed_by_user, reviewed_at: Time.current, denial_reason: reason)
  end

  def cancel
    update(status: :cancelled)
  end

  private

  def snapshot_coin_cost
    self.coin_cost ||= reward&.coin_cost
  end

  def reward_must_be_active
    errors.add(:reward, "is archived") if reward && !reward.active?
  end

  def sufficient_balance_at_request
    return unless claimee && coin_cost

    errors.add(:coin_cost, "exceeds the member's coin balance") if claimee.coin_balance < coin_cost
  end

  def status_transitions_from_pending_approval
    errors.add(:status, "cannot be changed once reviewed") unless status_was == "pending_approval"
  end
end
