# Pure date-math: expands a recurring Event's rule (frequency/interval/byday/
# until) into the UTC instants ("occurrence_start_at") where an occurrence
# begins within a given range. Does not know about exceptions/cancellations -
# see OccurrenceMaterializer for that layer.
#
# `range` must be a bounded Range of Time/ActiveSupport::TimeWithZone - the
# caller (OccurrenceMaterializer, the iCal feed, etc.) is responsible for
# keeping it reasonably sized; this class does not impose its own horizon.
#
# The wall-clock time-of-day is always taken from the event's own starts_at,
# interpreted in the event's timezone, then re-localized onto each candidate
# date. That's what keeps recurrence DST-correct: a 5pm Tuesday practice
# stays 5pm Tuesday local time across a DST transition instead of drifting an
# hour in UTC terms.
class RecurrenceExpander
  RRULE_WEEKDAY_CODES = %w[SU MO TU WE TH FR SA].freeze

  def self.call(event:, range:)
    new(event: event, range: range).call
  end

  def initialize(event:, range:)
    @event = event
    @range = range
  end

  def call
    return [] unless @event.recurring?

    series_start_date = local_date(@event.starts_at)
    window_start_date = [ local_date(@range.begin), series_start_date ].max
    window_end_date = local_date(@range.end)
    window_end_date = [ window_end_date, @event.recurrence_until ].min if @event.recurrence_until

    return [] if window_end_date < window_start_date

    dates = candidate_dates(series_start_date, window_start_date, window_end_date)
    # Expanding by date can produce a candidate on a boundary date whose
    # actual local time falls just outside the (time-precise) range - filter
    # against the real range, not just the date it happens to land on.
    dates.map { |date| localize(date) }.select { |time| @range.cover?(time) }.sort
  end

  private

  def candidate_dates(series_start_date, window_start_date, window_end_date)
    case @event.recurrence_frequency
    when "daily" then daily_dates(series_start_date, window_start_date, window_end_date)
    when "weekly" then weekly_dates(series_start_date, window_start_date, window_end_date)
    when "monthly" then monthly_dates(series_start_date, window_start_date, window_end_date)
    when "yearly" then yearly_dates(series_start_date, window_start_date, window_end_date)
    end
  end

  def daily_dates(series_start_date, window_start_date, window_end_date)
    interval = @event.recurrence_interval || 1
    dates = []
    date = series_start_date
    while date <= window_end_date
      dates << date if date >= window_start_date
      date += interval
    end
    dates
  end

  def weekly_dates(series_start_date, window_start_date, window_end_date)
    interval = @event.recurrence_interval || 1
    byday = @event.recurrence_byday.presence || [ RRULE_WEEKDAY_CODES[series_start_date.wday] ]
    offsets = byday.map { |code| RRULE_WEEKDAY_CODES.index(code) }.compact

    series_week_start = series_start_date - series_start_date.wday # preceding Sunday
    dates = []
    week_start = series_week_start
    week_index = 0
    while week_start <= window_end_date
      if (week_index % interval).zero?
        offsets.each do |offset|
          date = week_start + offset
          next if date < series_start_date

          dates << date if date >= window_start_date && date <= window_end_date
        end
      end
      week_start += 7
      week_index += 1
    end
    dates
  end

  def monthly_dates(series_start_date, window_start_date, window_end_date)
    interval = @event.recurrence_interval || 1
    day_of_month = series_start_date.day

    dates = []
    month_cursor = series_start_date.beginning_of_month
    month_index = 0
    while month_cursor <= window_end_date
      if (month_index % interval).zero?
        date = clamp_to_month(month_cursor.year, month_cursor.month, day_of_month)
        dates << date if date >= series_start_date && date >= window_start_date && date <= window_end_date
      end
      month_cursor = month_cursor.next_month
      month_index += 1
    end
    dates
  end

  def yearly_dates(series_start_date, window_start_date, window_end_date)
    interval = @event.recurrence_interval || 1

    dates = []
    year = series_start_date.year
    while Date.new(year, 1, 1) <= window_end_date
      if ((year - series_start_date.year) % interval).zero?
        date = yearly_date_for(year, series_start_date)
        dates << date if date && date >= series_start_date && date >= window_start_date && date <= window_end_date
      end
      year += 1
    end
    dates
  end

  # Clamped to the last day of a shorter month, e.g. a 31st-of-month series
  # lands on Feb 28 (or 29) in February.
  def clamp_to_month(year, month, day)
    Date.new(year, month, [ day, Date.new(year, month, -1).day ].min)
  end

  # A Feb 29 series simply has no occurrence in a non-leap year.
  def yearly_date_for(year, series_start_date)
    Date.new(year, series_start_date.month, series_start_date.day)
  rescue ArgumentError
    nil
  end

  def local_date(time)
    event_timezone.utc_to_local(time.to_time.utc).to_date
  end

  def localize(date)
    local_start = event_timezone.utc_to_local(@event.starts_at.to_time.utc)
    naive_local = Time.utc(date.year, date.month, date.day, local_start.hour, local_start.min, local_start.sec)
    event_timezone.local_to_utc(naive_local)
  end

  def event_timezone
    @event_timezone ||= ActiveSupport::TimeZone[@event.timezone]
  end
end
