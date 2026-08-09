require "test_helper"

class EventReminderTest < ActiveSupport::TestCase
  test "invalid with a non-positive minutes_before" do
    reminder = EventReminder.new(event: events(:family_dinner), minutes_before: 0)
    assert_not reminder.valid?
  end

  test "valid without a user (applies to all participants)" do
    reminder = EventReminder.new(event: events(:family_dinner), minutes_before: 30)
    assert reminder.valid?
  end

  test "valid with a user (that user's own reminder)" do
    reminder = EventReminder.new(event: events(:family_dinner), minutes_before: 30, user: users(:jane_admin))
    assert reminder.valid?
  end
end
