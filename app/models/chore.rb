class Chore < ApplicationRecord
  belongs_to :family
  belongs_to :assignee, class_name: "Membership", optional: true
  belongs_to :created_by_user, class_name: "User"
  has_many :chore_completions, dependent: :destroy

  enum :status, { active: 0, archived: 1 }, default: :active
  enum :recurrence_frequency, { daily: 0, weekly: 1, monthly: 2, yearly: 3 }
  enum :category, { household: 0, outdoor: 1, pet_care: 2, personal_care: 3, homework: 4, other: 5 }

  # Fixed per-category color, from the same palette Membership#color uses
  CATEGORY_COLORS = {
    "household" => "blue",
    "outdoor" => "green",
    "pet_care" => "amber",
    "personal_care" => "violet",
    "homework" => "indigo",
    "other" => "cyan"
  }.freeze

  validates :title, presence: true
  validates :coin_value, presence: true, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :starts_on, presence: true
  validates :recurrence_interval, numericality: { greater_than: 0, only_integer: true }, if: :recurring?
  validate :recurrence_until_not_before_starts_on
  validate :recurrence_byday_only_for_weekly

  scope :active, -> { where(status: :active) }

  def recurring?
    recurrence_frequency.present?
  end

  def unassigned?
    assignee_id.nil?
  end

  def category_color
    category && CATEGORY_COLORS[category]
  end

  def archive
    update(status: :archived)
  end

  def complete(completed_by_membership:, due_on:, completed_at: Time.current)
    chore_completions.create(completed_by_membership: completed_by_membership, due_on: due_on, completed_at: completed_at)
  end

  private

  def recurrence_until_not_before_starts_on
    return if recurrence_until.blank? || starts_on.blank?

    errors.add(:recurrence_until, "must be on or after starts_on") if recurrence_until < starts_on.to_date
  end

  def recurrence_byday_only_for_weekly
    return if recurrence_byday.blank?

    errors.add(:recurrence_byday, "can only be set for a weekly recurrence") unless weekly?
  end
end
