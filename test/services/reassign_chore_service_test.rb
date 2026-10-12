require "test_helper"

class ReassignChoreServiceTest < ActiveSupport::TestCase
  setup do
    @family = families(:smith_family)
    @owner = users(:lazaro_nixon)
    @sam = memberships(:sam_child_smith)
    @alex = memberships(:alex_adult_smith)
  end

  test "reassigns a one-off chore in place" do
    chore = @family.chores.create!(assignee: @sam, created_by_user: @owner, title: "Vacuum", coin_value: 3, starts_on: Date.current)

    result = ReassignChoreService.call(actor: @owner, chore: chore, new_assignee: @alex)

    assert result.success?
    assert_equal chore.id, result.data.id
    assert_equal @alex.id, chore.reload.assignee_id
  end

  test "fails cleanly when reassigning to the current assignee" do
    chore = @family.chores.create!(assignee: @sam, created_by_user: @owner, title: "Vacuum", coin_value: 3, starts_on: Date.current)

    result = ReassignChoreService.call(actor: @owner, chore: chore, new_assignee: @sam)

    assert result.failure?
    assert_equal @sam.id, chore.reload.assignee_id
  end

  test "reassigning a recurring chore splits it into a new series and archives the old one" do
    chore = @family.chores.create!(
      assignee: @sam, created_by_user: @owner, title: "Dishes", coin_value: 5, starts_on: 1.week.ago.to_date,
      recurrence_frequency: :daily, recurrence_interval: 1, recurrence_until: Date.current + 30,
    )
    old_completion = chore.complete(completed_by_membership: @sam, due_on: Date.current)
    assert old_completion.persisted?

    result = ReassignChoreService.call(actor: @owner, chore: chore, new_assignee: @alex)
    new_chore = result.data

    assert result.success?
    assert_not_equal chore.id, new_chore.id
    assert_equal @alex.id, new_chore.assignee_id
    assert_equal Date.current, new_chore.starts_on.to_date
    assert_equal Date.current + 30, new_chore.recurrence_until
    assert_equal chore.title, new_chore.title
    assert_equal chore.coin_value, new_chore.coin_value
    assert_equal chore.recurrence_frequency, new_chore.recurrence_frequency

    chore.reload
    assert_equal "archived", chore.status
    assert_equal Date.current - 1, chore.recurrence_until
    assert_equal @sam.id, chore.assignee_id, "old chore keeps its original assignee for history"
    assert_equal chore.id, old_completion.reload.chore_id, "existing completion stays on the old chore"
  end

  test "claiming an unassigned recurring chore splits it the same way" do
    chore = @family.chores.create!(
      assignee: nil, created_by_user: @owner, title: "Trash", coin_value: 2, starts_on: Date.current,
      recurrence_frequency: :weekly, recurrence_interval: 1,
    )

    result = ReassignChoreService.call(actor: @owner, chore: chore, new_assignee: @sam)

    assert result.success?
    assert_equal @sam.id, result.data.assignee_id
    assert_nil chore.reload.assignee_id
    assert_equal "archived", chore.status
  end
end
