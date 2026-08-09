class EventSerializer < ApplicationSerializer
  private

  def serialize(event)
    {
      id: event.id,
      family_id: event.family_id,
      title: event.title,
      description: event.description,
      location: event.location,
      category: event.category,
      timezone: event.timezone,
      all_day: event.all_day,
      starts_at: event.starts_at,
      ends_at: event.ends_at,
      recurrence_frequency: event.recurrence_frequency,
      recurrence_interval: event.recurrence_interval,
      recurrence_byday: event.recurrence_byday,
      recurrence_until: event.recurrence_until,
      created_by: PersonSerializer.new(event.created_by_user.person).as_json,
      participants: event.people.map { |person| PersonSerializer.new(person).as_json },
    }
  end
end
