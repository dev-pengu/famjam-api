# The single read-path for "what's on the calendar": expands non-recurring
# events verbatim and recurring events via RecurrenceExpander, resolving any
# EventOccurrenceException for each recurring occurrence along the way.
# Used by the events index, conflict detection, reminders, agenda emails, and
# the iCal feed - one place that understands recurrence + exceptions.
class OccurrenceMaterializer
  def self.call(family:, range:, participant_person_id: nil, event_id: nil)
    new(family: family, range: range, participant_person_id: participant_person_id, event_id: event_id).call
  end

  def initialize(family:, range:, participant_person_id: nil, event_id: nil)
    @family = family
    @range = range
    @participant_person_id = participant_person_id
    @event_id = event_id
  end

  def call
    occurrences = events_scope.flat_map do |event|
      event.recurring? ? recurring_occurrences(event) : non_recurring_occurrence(event)
    end

    occurrences.sort_by(&:starts_at)
  end

  private

  def events_scope
    scope = @family.events.includes(:event_occurrence_exceptions, :people, created_by_user: :person)
    scope = scope.where(id: @event_id) if @event_id
    return scope unless @participant_person_id

    scope.joins(:event_participants).where(event_participants: { person_id: @participant_person_id })
  end

  def non_recurring_occurrence(event)
    return [] unless overlaps_range?(event.starts_at, event.ends_at)

    [build_occurrence(event, occurrence_start_at: event.starts_at, starts_at: event.starts_at, ends_at: event.ends_at,
                       title: event.title, description: event.description, location: event.location,
                       category: event.category)]
  end

  def recurring_occurrences(event)
    duration = event.ends_at - event.starts_at
    exceptions_by_start = event.event_occurrence_exceptions.index_by { |exception| exception.occurrence_start_at.utc.iso8601 }

    RecurrenceExpander.call(event: event, range: @range).filter_map do |occurrence_start_at|
      exception = exceptions_by_start[occurrence_start_at.utc.iso8601]
      next if exception&.cancelled?

      build_occurrence(
        event, occurrence_start_at: occurrence_start_at,
        starts_at: exception&.starts_at || occurrence_start_at,
        ends_at: exception&.ends_at || occurrence_start_at + duration,
        title: exception&.title || event.title,
        description: exception&.description || event.description,
        location: exception&.location || event.location,
        category: exception&.category || event.category,
        exception: exception,
      )
    end
  end

  def build_occurrence(event, exception: nil, **attrs)
    EventOccurrence.new(event: event, exception: exception, **attrs)
  end

  def overlaps_range?(starts_at, ends_at)
    starts_at < @range.end && ends_at > @range.begin
  end
end
