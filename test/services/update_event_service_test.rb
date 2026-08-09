require "test_helper"

class UpdateEventServiceTest < ActiveSupport::TestCase
  setup do
    @family = families(:smith_family)
    @event = Event.create!(
      family: @family, created_by_user: users(:jane_admin), title: "Practice", timezone: "America/Chicago",
      starts_at: 1.day.from_now, ends_at: 1.day.from_now + 1.hour,
    )
    @event.event_participants.create!(person: people(:jane_admin))
  end

  test "updating a plain field does not touch participants" do
    result = UpdateEventService.call(event: @event, attributes: { title: "Renamed Practice" })

    assert result.success?
    assert_equal "Renamed Practice", @event.reload.title
    assert_equal [ people(:jane_admin) ], @event.people
  end

  test "participant_person_ids reconciles the participant list (adds and removes)" do
    result = UpdateEventService.call(
      event: @event,
      attributes: { participant_person_ids: [ people(:alex_adult).id ] },
    )

    assert result.success?
    assert_equal [ people(:alex_adult) ], @event.reload.people
  end

  test "an empty participant_person_ids array explicitly clears participants" do
    result = UpdateEventService.call(event: @event, attributes: { participant_person_ids: [] })

    assert result.success?
    assert_empty @event.reload.people
  end

  test "include_all_family_members snapshots current active members" do
    result = UpdateEventService.call(event: @event, attributes: { include_all_family_members: true })

    assert result.success?
    assert_equal @family.memberships.active.pluck(:person_id).sort, @event.reload.people.ids.sort
  end
end
