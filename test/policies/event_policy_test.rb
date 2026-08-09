require "test_helper"

class EventPolicyTest < ActiveSupport::TestCase
  setup do
    @family = families(:smith_family)
    @event = events(:family_dinner) # created by jane_admin; participants include sam_child (managed)
  end

  test "creator can update and destroy" do
    policy = policy_for(users(:jane_admin))
    assert policy.update?
    assert policy.destroy?
  end

  test "owner can update even if not the creator" do
    policy = policy_for(users(:lazaro_nixon))
    assert policy.update?
  end

  test "admin can update even if not the creator" do
    # jane_admin is both admin and creator here; use a second event created by someone else
    other_event = Event.create!(
      family: @family, created_by_user: users(:alex_adult), title: "Checkup",
      timezone: "America/Chicago", starts_at: 1.day.from_now, ends_at: 1.day.from_now + 1.hour,
    )
    policy = policy_for(users(:jane_admin), record: other_event)
    assert policy.update?
  end

  test "guardian of a managed participant can update even if not creator, owner, or admin" do
    # alex_adult is a registered guardian of sam_child, who participates in family_dinner,
    # but alex_adult is neither the creator (jane_admin) nor owner/admin.
    policy = policy_for(users(:alex_adult))
    assert policy.update?
  end

  test "an adult with no relation to the event cannot update or destroy" do
    policy = policy_for(users(:morgan_adult))
    assert_not policy.update?
    assert_not policy.destroy?
  end

  test "a member of a different family cannot access the event at all" do
    policy = policy_for(users(:pat_owner2))
    assert_not policy.show?
    assert_not policy.update?
    assert_not policy.destroy?
  end

  private

  def policy_for(user, record: @event)
    context = PunditUserContext.new(user: user, family: @family)
    EventPolicy.new(context, record)
  end
end
