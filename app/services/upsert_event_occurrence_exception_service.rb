# Handles both "edit just this occurrence" (status: modified) and "delete
# just this occurrence" (status: cancelled) - both are the same upsert, keyed
# on (event_id, occurrence_start_at), just with a different status/attrs.
class UpsertEventOccurrenceExceptionService < ApplicationService
  def initialize(actor:, event:, occurrence_start_at:, status:, attributes: {})
    @actor = actor
    @event = event
    @occurrence_start_at = occurrence_start_at
    @status = status
    @attributes = attributes
  end

  def call
    return ServiceResult.failure(['occurrence_start_at is not a valid occurrence of this event']) unless valid_occurrence?

    exception = @event.event_occurrence_exceptions.find_or_initialize_by(occurrence_start_at: @occurrence_start_at)
    exception.created_by_user ||= @actor
    exception.assign_attributes(@attributes.merge(status: @status))
    exception.save!

    ServiceResult.success(exception)
  rescue ActiveRecord::RecordInvalid => e
    ServiceResult.failure(e.record.errors.full_messages)
  end

  private

  def valid_occurrence?
    window = (@occurrence_start_at - 1.second)..(@occurrence_start_at + 1.second)
    RecurrenceExpander.call(event: @event, range: window).any? { |time| time == @occurrence_start_at }
  end
end
