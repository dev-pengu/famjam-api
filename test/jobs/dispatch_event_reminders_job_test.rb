require "test_helper"

class DispatchEventRemindersJobTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup do
    @family = families(:smith_family)
    @event = Event.create!(
      family: @family, created_by_user: users(:jane_admin), title: "Practice", timezone: "America/Chicago",
      starts_at: 32.minutes.from_now, ends_at: 32.minutes.from_now + 1.hour,
    )
    @event.event_participants.create!(person: people(:alex_adult))
    @reminder = @event.event_reminders.create!(minutes_before: 30) # applies to all participants
  end

  test "sends a reminder for an occurrence coming due within the run window" do
    assert_enqueued_emails 1 do
      DispatchEventRemindersJob.perform_now
    end

    delivery = EventReminderDelivery.last
    assert_equal @reminder, delivery.event_reminder
    assert_equal users(:alex_adult), delivery.user
  end

  test "does not send the same reminder twice across two runs" do
    DispatchEventRemindersJob.perform_now

    assert_no_enqueued_emails do
      DispatchEventRemindersJob.perform_now
    end
  end

  test "does not send to a participant who opted out" do
    users(:alex_adult).notification_preferences.create!(notification_type: :event_reminder, enabled: false)

    assert_no_enqueued_emails do
      DispatchEventRemindersJob.perform_now
    end
  end

  test "does not send to a managed (no-login) participant" do
    @event.event_participants.create!(person: people(:sam_child))

    assert_enqueued_emails 1 do # only alex_adult, not sam_child who has no login/email
      DispatchEventRemindersJob.perform_now
    end
  end

  test "does not send when the reminder isn't due yet" do
    @reminder.update!(minutes_before: 5) # occurrence is 32 minutes out, reminder is only 5 minutes before

    assert_no_enqueued_emails do
      DispatchEventRemindersJob.perform_now
    end
  end

  test "a user-specific reminder only notifies that user" do
    @reminder.update!(user: users(:alex_adult))
    @event.event_participants.create!(person: people(:jane_admin))

    assert_enqueued_emails 1 do
      DispatchEventRemindersJob.perform_now
    end
    assert_equal users(:alex_adult), EventReminderDelivery.last.user
  end
end
