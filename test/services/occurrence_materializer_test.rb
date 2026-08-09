require "test_helper"

class OccurrenceMaterializerTest < ActiveSupport::TestCase
  setup do
    @family = families(:smith_family)
    @range = 1.month.ago..1.month.from_now
  end

  test "includes non-recurring events verbatim" do
    occurrences = OccurrenceMaterializer.call(family: @family, range: @range)
    dinner = occurrences.find { |o| o.event == events(:family_dinner) }

    assert dinner
    assert_not dinner.series?
    assert_equal events(:family_dinner).starts_at, dinner.starts_at
  end

  test "expands a recurring event and excludes cancelled occurrences" do
    event = recurring_weekly_event
    occurrence_dates = RecurrenceExpander.call(event: event, range: @range)
    cancelled_at = occurrence_dates[1]

    event.event_occurrence_exceptions.create!(
      occurrence_start_at: cancelled_at, status: :cancelled, created_by_user: users(:jane_admin),
    )

    occurrences = OccurrenceMaterializer.call(family: @family, range: @range).select { |o| o.event == event }

    assert_equal occurrence_dates.size - 1, occurrences.size
    assert_not_includes occurrences.map(&:occurrence_start_at), cancelled_at
  end

  test "a modified occurrence reflects overrides with per-column fallback to the parent" do
    event = recurring_weekly_event
    occurrence_dates = RecurrenceExpander.call(event: event, range: @range)
    modified_at = occurrence_dates[1]

    event.event_occurrence_exceptions.create!(
      occurrence_start_at: modified_at, status: :modified, title: "Rescheduled Practice",
      created_by_user: users(:jane_admin),
    )

    occurrences = OccurrenceMaterializer.call(family: @family, range: @range).select { |o| o.event == event }
    modified_occurrence = occurrences.find { |o| o.occurrence_start_at == modified_at }

    assert modified_occurrence.modified?
    assert_equal "Rescheduled Practice", modified_occurrence.title
    assert_nil modified_occurrence.location # untouched column falls back to the parent, which is also nil here
  end

  test "filters to occurrences for a given participant" do
    # alex_adult participates in family_dinner but not sams_dentist
    occurrences = OccurrenceMaterializer.call(family: @family, range: @range, participant_person_id: people(:alex_adult).id)
    events_included = occurrences.map(&:event)

    assert_includes events_included, events(:family_dinner)
    assert_not_includes events_included, events(:sams_dentist)
  end

  private

  def recurring_weekly_event
    Event.create!(
      family: @family, created_by_user: users(:jane_admin), title: "Practice", timezone: "America/Chicago",
      starts_at: 2.weeks.ago, ends_at: 2.weeks.ago + 1.hour, recurrence_frequency: :weekly, recurrence_interval: 1,
    )
  end
end
