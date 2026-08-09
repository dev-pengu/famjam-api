require "test_helper"

class CreateEventServiceTest < ActiveSupport::TestCase
  setup do
    @family = families(:smith_family)
    @actor = users(:jane_admin)
  end

  test "creates an event with explicit participants" do
    result = CreateEventService.call(
      actor: @actor, family: @family, title: "Book Club", timezone: "America/Chicago",
      starts_at: 1.day.from_now, ends_at: 1.day.from_now + 1.hour,
      participant_person_ids: [people(:jane_admin).id],
    )

    assert result.success?
    event = result.data
    assert_equal @actor, event.created_by_user
    assert_equal [people(:jane_admin)], event.people
  end

  test "whole-family events snapshot the family's active members at creation time" do
    result = CreateEventService.call(
      actor: @actor, family: @family, title: "Family Vacation", timezone: "America/Chicago",
      starts_at: 1.week.from_now, ends_at: 2.weeks.from_now, include_all_family_members: true,
    )

    assert result.success?
    event = result.data
    assert_equal @family.memberships.active.pluck(:person_id).sort, event.people.ids.sort

    # A member added to the family later is not retroactively added to the
    # already-created whole-family event.
    new_person = Person.create!(first_name: "New", last_name: "Member")
    @family.memberships.create!(person: new_person, role: :adult, status: :active, joined_at: Time.current)
    assert_not_includes event.reload.people, new_person
  end

  test "fails with validation errors when required attributes are missing" do
    result = CreateEventService.call(
      actor: @actor, family: @family, title: "", timezone: "America/Chicago",
      starts_at: 1.day.from_now, ends_at: 1.day.from_now + 1.hour,
    )

    assert result.failure?
    assert_includes result.errors, "Title can't be blank"
  end
end
