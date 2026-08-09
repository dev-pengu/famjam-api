class Event < ApplicationRecord
  belongs_to :family
  belongs_to :created_by_user, class_name: "User"

  has_many :event_participants, dependent: :destroy
  has_many :people, through: :event_participants
  has_many :event_occurrence_exceptions, dependent: :destroy
  has_many :event_reminders, dependent: :destroy

  enum :category, { school: 0, practice_sports: 1, medical: 2, travel: 3 }, prefix: true
  enum :recurrence_frequency, { daily: 0, weekly: 1, monthly: 2, yearly: 3 }, prefix: :recurs

  validates :title, presence: true
  validates :timezone, presence: true, inclusion: { in: ActiveSupport::TimeZone::MAPPING.values }
  validate :ends_after_starts
  validate :recurrence_byday_only_valid_when_weekly

  def recurring?
    recurrence_frequency.present?
  end

  private

  def ends_after_starts
    return if starts_at.blank? || ends_at.blank?

    errors.add(:ends_at, "must be on or after starts_at") if ends_at < starts_at
  end

  def recurrence_byday_only_valid_when_weekly
    return if recurrence_byday.blank?

    errors.add(:recurrence_byday, "is only valid for weekly recurrence") unless recurs_weekly?
  end
end
