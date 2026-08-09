class CoinTransaction < ApplicationRecord
  belongs_to :membership
  belongs_to :created_by_user, class_name: "User"

  enum :kind, { credit: 0, debit: 1 }

  validates :amount, presence: true, numericality: { other_than: 0, only_integer: true }
  validates :note, presence: true, if: :debit?
  validate :amount_sign_matches_kind
  validate :sufficient_balance, if: :debit?

  before_validation :set_balance_after, on: :create

  private

  def amount_sign_matches_kind
    return if amount.blank?

    if credit? && amount <= 0
      errors.add(:amount, "must be positive for a credit")
    elsif debit? && amount >= 0
      errors.add(:amount, "must be negative for a debit")
    end
  end

  def sufficient_balance
    return unless membership && amount

    errors.add(:amount, "exceeds available coin balance") if membership.coin_balance + amount < 0
  end

  def set_balance_after
    return unless membership && amount

    self.balance_after = membership.coin_balance + amount
  end
end
