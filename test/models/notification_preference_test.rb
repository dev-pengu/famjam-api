require "test_helper"

class NotificationPreferenceTest < ActiveSupport::TestCase
  test "only one preference row per user per notification_type" do
    user = users(:jane_admin)
    user.notification_preferences.create!(notification_type: :event_reminder, enabled: false)

    duplicate = user.notification_preferences.new(notification_type: :event_reminder, enabled: true)
    assert_not duplicate.valid?
  end
end

class UserNotifiesForTest < ActiveSupport::TestCase
  test "a missing preference row defaults to enabled (opt-out model)" do
    assert users(:jane_admin).notifies_for?(:event_reminder)
  end

  test "an explicit disabled row is respected" do
    user = users(:jane_admin)
    user.notification_preferences.create!(notification_type: :event_reminder, enabled: false)
    assert_not user.notifies_for?(:event_reminder)
  end

  test "an explicit enabled row is respected" do
    user = users(:jane_admin)
    user.notification_preferences.create!(notification_type: :event_reminder, enabled: true)
    assert user.notifies_for?(:event_reminder)
  end
end
