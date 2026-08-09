class AddEventParticipantService < ApplicationService
  def initialize(event:, person:)
    @event = event
    @person = person
  end

  def call
    participant = @event.event_participants.create!(person: @person)
    ServiceResult.success(participant)
  rescue ActiveRecord::RecordInvalid => e
    ServiceResult.failure(e.record.errors.full_messages)
  end
end
