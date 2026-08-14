require "test_helper"

class ChoreOccurrencesQueryTest < ActiveSupport::TestCase
  setup do
    @family = families(:smith_family)
    @owner = users(:lazaro_nixon)
    @sam = memberships(:sam_child_smith)
    @alex = memberships(:alex_adult_smith)
  end

  def build_chore(**overrides)
    @family.chores.create!({
      assignee: @sam, created_by_user: @owner, title: "Dishes", coin_value: 5, starts_on: Date.new(2026, 1, 1)
    }.merge(overrides))
  end

  test "expands a recurring chore into one occurrence per due date, outstanding by default" do
    build_chore(recurrence_frequency: :daily, recurrence_interval: 1)

    occurrences = ChoreOccurrencesQuery.call(family: @family, range: Date.new(2026, 1, 1)..Date.new(2026, 1, 3))

    assert_equal [ Date.new(2026, 1, 1), Date.new(2026, 1, 2), Date.new(2026, 1, 3) ], occurrences.map(&:due_on)
    assert occurrences.all? { |o| o.status == "outstanding" }
    assert occurrences.all?(&:series?)
  end

  test "a one-off chore appears only on its starts_on date" do
    build_chore(starts_on: Date.new(2026, 1, 5))

    occurrences = ChoreOccurrencesQuery.call(family: @family, range: Date.new(2026, 1, 1)..Date.new(2026, 1, 10))

    assert_equal [ Date.new(2026, 1, 5) ], occurrences.map(&:due_on)
    assert_not occurrences.first.series?
  end

  test "a one-off chore outside the range does not appear" do
    build_chore(starts_on: Date.new(2026, 1, 5))

    occurrences = ChoreOccurrencesQuery.call(family: @family, range: Date.new(2026, 2, 1)..Date.new(2026, 2, 10))

    assert_equal [], occurrences
  end

  test "merges in a recorded completion for its due date" do
    chore = build_chore(recurrence_frequency: :daily, recurrence_interval: 1)
    completion = chore.complete(completed_by_membership: @sam, due_on: Date.new(2026, 1, 2))
    assert completion.persisted?

    occurrences = ChoreOccurrencesQuery.call(family: @family, range: Date.new(2026, 1, 1)..Date.new(2026, 1, 3))
    by_date = occurrences.index_by(&:due_on)

    assert_equal "outstanding", by_date[Date.new(2026, 1, 1)].status
    assert_equal "pending_approval", by_date[Date.new(2026, 1, 2)].status
    assert_equal completion, by_date[Date.new(2026, 1, 2)].completion
    assert_equal "outstanding", by_date[Date.new(2026, 1, 3)].status
  end

  test "excludes archived chores" do
    chore = build_chore(recurrence_frequency: :daily, recurrence_interval: 1)
    chore.archive

    occurrences = ChoreOccurrencesQuery.call(family: @family, range: Date.new(2026, 1, 1)..Date.new(2026, 1, 3))
    assert_equal [], occurrences
  end

  test "filters by assignee_id" do
    build_chore(assignee: @sam, starts_on: Date.new(2026, 1, 5))
    build_chore(assignee: @alex, starts_on: Date.new(2026, 1, 5))

    occurrences = ChoreOccurrencesQuery.call(
      family: @family, range: Date.new(2026, 1, 1)..Date.new(2026, 1, 10), assignee_id: @sam.id,
    )

    assert_equal [ @sam.id ], occurrences.map { |o| o.chore.assignee_id }.uniq
  end

  test "filters by chore_id" do
    chore1 = build_chore(starts_on: Date.new(2026, 1, 5))
    build_chore(starts_on: Date.new(2026, 1, 5))

    occurrences = ChoreOccurrencesQuery.call(
      family: @family, range: Date.new(2026, 1, 1)..Date.new(2026, 1, 10), chore_id: chore1.id,
    )

    assert_equal [ chore1.id ], occurrences.map { |o| o.chore.id }.uniq
  end

  test "sorts occurrences across chores by due date" do
    build_chore(title: "A", starts_on: Date.new(2026, 1, 9))
    build_chore(title: "B", starts_on: Date.new(2026, 1, 2))

    occurrences = ChoreOccurrencesQuery.call(family: @family, range: Date.new(2026, 1, 1)..Date.new(2026, 1, 10))

    assert_equal [ Date.new(2026, 1, 2), Date.new(2026, 1, 9) ], occurrences.map(&:due_on)
  end
end
