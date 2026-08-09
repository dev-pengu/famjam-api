require "test_helper"

class IcalFeedGeneratorServiceTest < ActiveSupport::TestCase
  test "generates a valid calendar with a UTC event for each occurrence" do
    ical = IcalFeedGeneratorService.call(user: users(:jane_admin))

    assert_match "BEGIN:VCALENDAR", ical
    assert_match "SUMMARY:Family Dinner", ical
    assert_match(/DTSTART:\d{8}T\d{6}Z/, ical) # the trailing Z marks it as UTC, not a floating/ambiguous time
  end

  test "excludes a cancelled occurrence, while other occurrences of the same series remain" do
    event = Event.create!(
      family: families(:smith_family), created_by_user: users(:jane_admin), title: "Weekly Practice",
      timezone: "America/Chicago", starts_at: 1.week.from_now, ends_at: 1.week.from_now + 1.hour,
      recurrence_frequency: :weekly, recurrence_interval: 1,
    )
    cancelled_at = RecurrenceExpander.call(event: event, range: Time.current..3.weeks.from_now).first
    event.event_occurrence_exceptions.create!(
      occurrence_start_at: cancelled_at, status: :cancelled, created_by_user: users(:jane_admin),
    )

    ical = IcalFeedGeneratorService.call(user: users(:jane_admin))
    assert_no_match "UID:#{event.id}-#{cancelled_at.to_i}@famjam", ical
    assert_match "SUMMARY:Weekly Practice", ical # a later, non-cancelled occurrence of the same series
  end

  test "only includes events from the user's own families" do
    ical = IcalFeedGeneratorService.call(user: users(:pat_owner2))
    assert_no_match "Family Dinner", ical # belongs to smith_family, pat is only in jones_family
  end
end
