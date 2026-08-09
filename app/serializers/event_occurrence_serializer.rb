class EventOccurrenceSerializer < ApplicationSerializer
  private

  def serialize(occurrence)
    {
      event_id: occurrence.event.id,
      occurrence_start_at: occurrence.occurrence_start_at,
      starts_at: occurrence.starts_at,
      ends_at: occurrence.ends_at,
      title: occurrence.title,
      description: occurrence.description,
      location: occurrence.location,
      category: occurrence.category,
      cancelled: occurrence.cancelled?,
      modified: occurrence.modified?,
      series: occurrence.series?,
      event: EventSerializer.new(occurrence.event).as_json,
    }
  end
end
