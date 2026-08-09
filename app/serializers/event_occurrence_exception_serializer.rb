class EventOccurrenceExceptionSerializer < ApplicationSerializer
  private

  def serialize(exception)
    {
      id: exception.id,
      event_id: exception.event_id,
      occurrence_start_at: exception.occurrence_start_at,
      status: exception.status,
      starts_at: exception.starts_at,
      ends_at: exception.ends_at,
      title: exception.title,
      description: exception.description,
      location: exception.location,
      category: exception.category,
    }
  end
end
