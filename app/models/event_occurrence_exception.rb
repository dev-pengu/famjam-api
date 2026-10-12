class EventOccurrenceException < ApplicationRecord
  belongs_to :event
  belongs_to :created_by_user, class_name: "User"

  enum :status, { modified: 0, cancelled: 1 }
  enum :category, { school: 0, practice_sports: 1, medical: 2, travel: 3 }, prefix: true

  validates :occurrence_start_at, presence: true, uniqueness: { scope: :event_id }
  validate :occurrence_start_at_is_a_real_occurrence

  # Handles both "edit just this occurrence" (status: modified) and "delete
  # just this occurrence" (status: cancelled) - both are the same upsert,
  # keyed on (event_id, occurrence_start_at), just with a different
  # status/attrs.
  def self.upsert_for_occurrence(event:, occurrence_start_at:, status:, actor:, attributes: {})
    exception = event.event_occurrence_exceptions.find_or_initialize_by(occurrence_start_at: occurrence_start_at)
    exception.created_by_user ||= actor
    exception.assign_attributes(attributes.merge(status: status))
    exception.save
    exception
  end

  private

  def occurrence_start_at_is_a_real_occurrence
    return if event.blank? || occurrence_start_at.blank?

    window = (occurrence_start_at - 1.second)..(occurrence_start_at + 1.second)
    return if RecurrenceExpander.call(event: event, range: window).any? { |time| time == occurrence_start_at }

    errors.add(:occurrence_start_at, "is not a valid occurrence of this event")
  end
end
