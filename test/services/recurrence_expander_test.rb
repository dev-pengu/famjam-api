require "test_helper"

class RecurrenceExpanderTest < ActiveSupport::TestCase
  def build_event(**overrides)
    Event.new({
      family: families(:smith_family), created_by_user: users(:jane_admin), title: "Recurring",
      timezone: "America/Chicago", ends_at: overrides[:starts_at] + 1.hour
    }.merge(overrides))
  end

  test "daily recurrence steps by the given interval" do
    event = build_event(starts_at: Time.utc(2026, 1, 1, 17), recurrence_frequency: :daily, recurrence_interval: 3)

    dates = RecurrenceExpander.call(event: event, range: Time.utc(2026, 1, 1)..Time.utc(2026, 1, 11)).map(&:to_date)

    assert_equal [ Date.new(2026, 1, 1), Date.new(2026, 1, 4), Date.new(2026, 1, 7), Date.new(2026, 1, 10) ], dates
  end

  test "weekly recurrence defaults to the series start's own weekday" do
    # 2026-01-06 is a Tuesday
    event = build_event(starts_at: Time.utc(2026, 1, 6, 23), recurrence_frequency: :weekly, recurrence_interval: 1)

    occurrences = RecurrenceExpander.call(event: event, range: Time.utc(2026, 1, 1)..Time.utc(2026, 1, 28))

    assert_equal %w[Tue Tue Tue Tue], occurrences.map { |t| t.strftime("%a") }
    assert_equal [ 6, 13, 20, 27 ], occurrences.map { |t| t.day }
  end

  test "weekly recurrence with an explicit byday list and interval" do
    # Mon+Wed+Fri, every other week, starting Monday 2026-01-05
    event = build_event(
      starts_at: Time.utc(2026, 1, 5, 23), recurrence_frequency: :weekly, recurrence_interval: 2,
      recurrence_byday: %w[MO WE FR],
    )

    occurrences = RecurrenceExpander.call(event: event, range: Time.utc(2026, 1, 1)..Time.utc(2026, 1, 31))
    days = occurrences.map(&:day).sort

    # Week of Jan 5 (included) and week of Jan 19 (every other week), not Jan 12 or Jan 26
    assert_equal [ 5, 7, 9, 19, 21, 23 ], days
  end

  test "weekly recurrence stays at the same local wall-clock time across a US DST transition" do
    # 2024-03-10 is when US clocks spring forward (2am -> 3am), a real past
    # transition so this test doesn't depend on future TZ database changes.
    event = build_event(starts_at: Time.utc(2024, 2, 27, 23), recurrence_frequency: :weekly, recurrence_interval: 1)

    occurrences = RecurrenceExpander.call(event: event, range: Time.utc(2024, 2, 20)..Time.utc(2024, 3, 20))
    local_hours = occurrences.map { |t| ActiveSupport::TimeZone["America/Chicago"].utc_to_local(t).hour }

    assert_equal [ 17, 17, 17, 17 ], local_hours # 5pm local every week, before AND after the DST boundary
  end

  test "monthly recurrence clamps to the last day of a shorter month" do
    event = build_event(starts_at: Time.utc(2023, 1, 31, 17), recurrence_frequency: :monthly, recurrence_interval: 1)

    occurrences = RecurrenceExpander.call(event: event, range: Time.utc(2023, 1, 1)..Time.utc(2023, 4, 1))

    assert_equal [ Date.new(2023, 1, 31), Date.new(2023, 2, 28), Date.new(2023, 3, 31) ], occurrences.map(&:to_date)
  end

  test "yearly recurrence skips a Feb 29 series in non-leap years" do
    event = build_event(starts_at: Time.utc(2024, 2, 29, 17), recurrence_frequency: :yearly, recurrence_interval: 1)

    occurrences = RecurrenceExpander.call(event: event, range: Time.utc(2024, 1, 1)..Time.utc(2028, 3, 1))

    assert_equal [ Date.new(2024, 2, 29), Date.new(2028, 2, 29) ], occurrences.map(&:to_date)
  end

  test "returns nothing for a non-recurring event" do
    event = build_event(starts_at: Time.utc(2026, 1, 1, 17))
    assert_equal [], RecurrenceExpander.call(event: event, range: Time.utc(2026, 1, 1)..Time.utc(2026, 2, 1))
  end

  test "respects recurrence_until as an inclusive series end" do
    event = build_event(
      starts_at: Time.utc(2026, 1, 1, 17), recurrence_frequency: :daily, recurrence_interval: 1,
      recurrence_until: Date.new(2026, 1, 3),
    )

    occurrences = RecurrenceExpander.call(event: event, range: Time.utc(2026, 1, 1)..Time.utc(2026, 1, 10))
    assert_equal [ 1, 2, 3 ], occurrences.map(&:day)
  end
end
