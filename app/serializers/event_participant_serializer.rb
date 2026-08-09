class EventParticipantSerializer < ApplicationSerializer
  private

  def serialize(event_participant)
    {
      id: event_participant.id,
      event_id: event_participant.event_id,
      person: PersonSerializer.new(event_participant.person).as_json,
    }
  end
end
