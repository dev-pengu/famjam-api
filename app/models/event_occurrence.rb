# A materialized calendar occurrence for display - either a one-off event
# taken verbatim, or one date in a recurring series after resolving any
# EventOccurrenceException for that date. Never persisted; built on the fly
# by OccurrenceMaterializer for a requested date range.
class EventOccurrence
  attr_reader :event, :occurrence_start_at, :starts_at, :ends_at, :title, :description, :location, :category,
              :exception

  def initialize(event:, occurrence_start_at:, starts_at:, ends_at:, title:, description:, location:, category:,
                  cancelled: false, exception: nil)
    @event = event
    @occurrence_start_at = occurrence_start_at
    @starts_at = starts_at
    @ends_at = ends_at
    @title = title
    @description = description
    @location = location
    @category = category
    @cancelled = cancelled
    @exception = exception
  end

  def cancelled? = @cancelled
  def modified? = exception&.modified? || false
  def series? = event.recurring?
end
