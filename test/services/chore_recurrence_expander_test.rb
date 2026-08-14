require "test_helper"

class ChoreRecurrenceExpanderTest < ActiveSupport::TestCase
  def build_chore(**overrides)
    Chore.new({
      family: families(:smith_family), created_by_user: users(:jane_admin), assignee: memberships(:sam_child_smith),
      title: "Recurring", coin_value: 1
    }.merge(overrides))
  end

  test "daily recurrence steps by the given interval" do
    chore = build_chore(starts_on: Date.new(2026, 1, 1), recurrence_frequency: :daily, recurrence_interval: 3)

    dates = ChoreRecurrenceExpander.call(chore: chore, range: Date.new(2026, 1, 1)..Date.new(2026, 1, 11))

    assert_equal [ Date.new(2026, 1, 1), Date.new(2026, 1, 4), Date.new(2026, 1, 7), Date.new(2026, 1, 10) ], dates
  end

  test "weekly recurrence defaults to the series start's own weekday" do
    # 2026-01-06 is a Tuesday
    chore = build_chore(starts_on: Date.new(2026, 1, 6), recurrence_frequency: :weekly, recurrence_interval: 1)

    dates = ChoreRecurrenceExpander.call(chore: chore, range: Date.new(2026, 1, 1)..Date.new(2026, 1, 28))

    assert_equal %w[Tue Tue Tue Tue], dates.map { |d| d.strftime("%a") }
    assert_equal [ 6, 13, 20, 27 ], dates.map(&:day)
  end

  test "weekly recurrence with an explicit byday list and interval" do
    # Mon+Wed+Fri, every other week, starting Monday 2026-01-05
    chore = build_chore(
      starts_on: Date.new(2026, 1, 5), recurrence_frequency: :weekly, recurrence_interval: 2,
      recurrence_byday: %w[MO WE FR],
    )

    dates = ChoreRecurrenceExpander.call(chore: chore, range: Date.new(2026, 1, 1)..Date.new(2026, 1, 31))

    # Week of Jan 5 (included) and week of Jan 19 (every other week), not Jan 12 or Jan 26
    assert_equal [ 5, 7, 9, 19, 21, 23 ], dates.map(&:day).sort
  end

  test "monthly recurrence clamps to the last day of a shorter month" do
    chore = build_chore(starts_on: Date.new(2023, 1, 31), recurrence_frequency: :monthly, recurrence_interval: 1)

    dates = ChoreRecurrenceExpander.call(chore: chore, range: Date.new(2023, 1, 1)..Date.new(2023, 4, 1))

    assert_equal [ Date.new(2023, 1, 31), Date.new(2023, 2, 28), Date.new(2023, 3, 31) ], dates
  end

  test "yearly recurrence skips a Feb 29 series in non-leap years" do
    chore = build_chore(starts_on: Date.new(2024, 2, 29), recurrence_frequency: :yearly, recurrence_interval: 1)

    dates = ChoreRecurrenceExpander.call(chore: chore, range: Date.new(2024, 1, 1)..Date.new(2028, 3, 1))

    assert_equal [ Date.new(2024, 2, 29), Date.new(2028, 2, 29) ], dates
  end

  test "returns nothing for a non-recurring chore" do
    chore = build_chore(starts_on: Date.new(2026, 1, 1))
    assert_equal [], ChoreRecurrenceExpander.call(chore: chore, range: Date.new(2026, 1, 1)..Date.new(2026, 2, 1))
  end

  test "respects recurrence_until as an inclusive series end" do
    chore = build_chore(
      starts_on: Date.new(2026, 1, 1), recurrence_frequency: :daily, recurrence_interval: 1,
      recurrence_until: Date.new(2026, 1, 3),
    )

    dates = ChoreRecurrenceExpander.call(chore: chore, range: Date.new(2026, 1, 1)..Date.new(2026, 1, 10))
    assert_equal [ 1, 2, 3 ], dates.map(&:day)
  end

  test "a window that starts before the series start clamps to the series start" do
    chore = build_chore(starts_on: Date.new(2026, 1, 10), recurrence_frequency: :daily, recurrence_interval: 1)

    dates = ChoreRecurrenceExpander.call(chore: chore, range: Date.new(2026, 1, 1)..Date.new(2026, 1, 12))
    assert_equal [ Date.new(2026, 1, 10), Date.new(2026, 1, 11), Date.new(2026, 1, 12) ], dates
  end
end
