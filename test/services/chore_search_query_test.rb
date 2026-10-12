require "test_helper"

class ChoreSearchQueryTest < ActiveSupport::TestCase
  setup do
    @family = families(:smith_family)
    @owner = users(:lazaro_nixon)
    @sam = memberships(:sam_child_smith)
    @alex = memberships(:alex_adult_smith)
  end

  def build_chore(**overrides)
    @family.chores.create!({
      created_by_user: @owner, title: "Chore", coin_value: 5, starts_on: Date.current
    }.merge(overrides))
  end

  test "filters by assignee_id" do
    mine = build_chore(assignee: @sam, title: "Mine")
    build_chore(assignee: @alex, title: "Not mine")

    results = ChoreSearchQuery.call(family: @family, assignee_id: @sam.id)

    assert_equal [ mine.id ], results.map(&:id)
  end

  test "filters to unassigned with the special assignee_id value" do
    open_chore = build_chore(assignee: nil, title: "Open")
    build_chore(assignee: @sam, title: "Assigned")

    results = ChoreSearchQuery.call(family: @family, assignee_id: "unassigned")

    assert_equal [ open_chore.id ], results.map(&:id)
  end

  test "filters by category" do
    household = build_chore(category: :household, title: "Household")
    build_chore(category: :outdoor, title: "Outdoor")

    results = ChoreSearchQuery.call(family: @family, category: "household")

    assert_equal [ household.id ], results.map(&:id)
  end

  test "filters by coin range" do
    build_chore(coin_value: 1, title: "Cheap")
    mid = build_chore(coin_value: 5, title: "Mid")
    build_chore(coin_value: 10, title: "Pricey")

    results = ChoreSearchQuery.call(family: @family, coin_min: "3", coin_max: "7")

    assert_equal [ mid.id ], results.map(&:id)
  end

  test "searches title and description" do
    build_chore(title: "Vacuum living room", description: nil)
    by_desc = build_chore(title: "Something else", description: "vacuum the stairs")
    build_chore(title: "Unrelated", description: "unrelated too")

    results = ChoreSearchQuery.call(family: @family, search: "vacuum")

    assert_equal 2, results.length
    assert_includes results.map(&:id), by_desc.id
  end

  test "sorts by due date (starts_on) by default" do
    later = build_chore(starts_on: Date.current + 5)
    sooner = build_chore(starts_on: Date.current + 1)

    results = ChoreSearchQuery.call(family: @family)

    assert_equal [ sooner.id, later.id ], results.map(&:id)
  end

  test "sorts newest first" do
    first = build_chore
    second = build_chore

    results = ChoreSearchQuery.call(family: @family, sort: "newest")

    assert_equal [ second.id, first.id ], results.map(&:id)
  end

  test "sorts by coins high to low and low to high" do
    low = build_chore(coin_value: 1)
    high = build_chore(coin_value: 10)

    assert_equal [ high.id, low.id ], ChoreSearchQuery.call(family: @family, sort: "coins_desc").map(&:id)
    assert_equal [ low.id, high.id ], ChoreSearchQuery.call(family: @family, sort: "coins_asc").map(&:id)
  end

  test "sorts by assignee with unassigned pinned to the top" do
    assigned_to_sam = build_chore(assignee: @sam)
    unassigned = build_chore(assignee: nil)

    results = ChoreSearchQuery.call(family: @family, sort: "assignee")

    assert_equal [ unassigned.id, assigned_to_sam.id ], results.map(&:id)
  end

  test "excludes archived chores" do
    chore = build_chore
    chore.archive

    assert_equal [], ChoreSearchQuery.call(family: @family).map(&:id)
  end

  test "falls back to the default sort for an unrecognized sort value" do
    sooner = build_chore(starts_on: Date.current + 1)
    later = build_chore(starts_on: Date.current + 5)

    results = ChoreSearchQuery.call(family: @family, sort: "not_a_real_sort")

    assert_equal [ sooner.id, later.id ], results.map(&:id)
  end
end
