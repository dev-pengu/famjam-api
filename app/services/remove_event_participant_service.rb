class RemoveEventParticipantService < ApplicationService
  def initialize(event_participant:)
    @event_participant = event_participant
  end

  def call
    @event_participant.destroy!
    ServiceResult.success(true)
  end
end
