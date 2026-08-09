# Builds a .ics calendar body covering all of a user's active families -
# used by the (unauthenticated, token-gated) iCal feed endpoint that external
# calendar apps poll on their own schedule. Occurrence times are emitted in
# UTC rather than with a TZID, which sidesteps needing to also emit a
# matching VTIMEZONE component while still being fully correct - calendar
# apps convert a UTC ("Z") time to the viewer's local time automatically.
class IcalFeedGeneratorService
  WINDOW_PAST = 3.months
  WINDOW_FUTURE = 12.months

  def self.call(user:)
    new(user: user).call
  end

  def initialize(user:)
    @user = user
  end

  def call
    calendar = Icalendar::Calendar.new
    calendar.append_custom_property("X-WR-CALNAME", "Famjam Calendar")

    each_occurrence { |occurrence| add_event(calendar, occurrence) }

    calendar.publish
    calendar.to_ical
  end

  private

  def each_occurrence
    range = (Time.current - WINDOW_PAST)..(Time.current + WINDOW_FUTURE)

    @user.families.distinct.each do |family|
      OccurrenceMaterializer.call(family: family, range: range).each do |occurrence|
        yield occurrence unless occurrence.cancelled?
      end
    end
  end

  def add_event(calendar, occurrence)
    calendar.event do |e|
      e.uid = "#{occurrence.event.id}-#{occurrence.occurrence_start_at.to_i}@famjam"
      # icalendar only emits the "Z" (UTC) suffix when explicitly told
      # tzid => 'UTC' - it does not infer it from the Time/TimeWithZone
      # object's own zone, so this must be passed explicitly or the output
      # is an invalid "floating" time with no zone information at all.
      e.dtstart = Icalendar::Values::DateTime.new(occurrence.starts_at, "tzid" => "UTC")
      e.dtend = Icalendar::Values::DateTime.new(occurrence.ends_at, "tzid" => "UTC")
      e.summary = occurrence.title
      e.description = occurrence.description if occurrence.description.present?
      e.location = occurrence.location if occurrence.location.present?
    end
  end
end
