class ChoreRecurrenceExpander
  RRULE_WEEKDAY_CODES = %w[SU MO TU WE TH FR SA].freeze

  def self.call(chore:, range:)
    new(chore: chore, range: range).call
  end

  def initialize(chore:, range:)
    @chore = chore
    @range = range
  end

  def call
    return [] unless @chore.recurring?

    series_start_date = @chore.starts_on.to_date
    window_start_date = [ @range.begin, series_start_date ].max
    window_end_date = @range.end
    window_end_date = [ window_end_date, @chore.recurrence_until ].min if @chore.recurrence_until

    return [] if window_end_date < window_start_date

    candidate_dates(series_start_date, window_start_date, window_end_date).sort
  end

  private

  def candidate_dates(series_start_date, window_start_date, window_end_date)
    case @chore.recurrence_frequency
    when "daily" then daily_dates(series_start_date, window_start_date, window_end_date)
    when "weekly" then weekly_dates(series_start_date, window_start_date, window_end_date)
    when "monthly" then monthly_dates(series_start_date, window_start_date, window_end_date)
    when "yearly" then yearly_dates(series_start_date, window_start_date, window_end_date)
    end
  end

  def daily_dates(series_start_date, window_start_date, window_end_date)
    interval = @chore.recurrence_interval || 1
    dates = []
    date = series_start_date
    while date <= window_end_date
      dates << date if date >= window_start_date
      date += interval
    end
    dates
  end

  def weekly_dates(series_start_date, window_start_date, window_end_date)
    interval = @chore.recurrence_interval || 1
    byday = @chore.recurrence_byday.presence || [ RRULE_WEEKDAY_CODES[series_start_date.wday] ]
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
    interval = @chore.recurrence_interval || 1
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
    interval = @chore.recurrence_interval || 1

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
end
