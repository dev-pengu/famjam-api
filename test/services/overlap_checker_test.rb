require "test_helper"

class OverlapCheckerTest < ActiveSupport::TestCase
  setup do
    @family = families(:smith_family)
    @person = people(:alex_adult)
    @existing = Event.create!(
      family: @family, created_by_user: users(:jane_admin), title: "Existing", timezone: "America/Chicago",
      starts_at: Time.utc(2026, 6, 1, 17), ends_at: Time.utc(2026, 6, 1, 18),
    )
    @existing.event_participants.create!(person: @person)
  end

  test "detects a true overlap for a shared participant" do
    overlaps = OverlapChecker.call(
      family: @family, participant_person_ids: [ @person.id ],
      starts_at: Time.utc(2026, 6, 1, 17, 30), ends_at: Time.utc(2026, 6, 1, 18, 30),
    )

    assert_equal [ @existing ], overlaps.map(&:event)
  end

  test "does not flag an adjacent, non-overlapping event" do
    overlaps = OverlapChecker.call(
      family: @family, participant_person_ids: [ @person.id ],
      starts_at: Time.utc(2026, 6, 1, 18), ends_at: Time.utc(2026, 6, 1, 19),
    )

    assert_empty overlaps
  end

  test "excludes the event being edited via exclude_event_id" do
    overlaps = OverlapChecker.call(
      family: @family, participant_person_ids: [ @person.id ],
      starts_at: Time.utc(2026, 6, 1, 17, 30), ends_at: Time.utc(2026, 6, 1, 18, 30),
      exclude_event_id: @existing.id,
    )

    assert_empty overlaps
  end

  test "only flags overlaps for participants actually on the existing event" do
    overlaps = OverlapChecker.call(
      family: @family, participant_person_ids: [ people(:morgan_adult).id ],
      starts_at: Time.utc(2026, 6, 1, 17, 30), ends_at: Time.utc(2026, 6, 1, 18, 30),
    )

    assert_empty overlaps
  end

  test "returns no overlaps when no participants are given" do
    overlaps = OverlapChecker.call(
      family: @family, participant_person_ids: [],
      starts_at: Time.utc(2026, 6, 1, 17, 30), ends_at: Time.utc(2026, 6, 1, 18, 30),
    )

    assert_empty overlaps
  end
end
