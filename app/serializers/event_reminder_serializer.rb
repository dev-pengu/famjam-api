class EventReminderSerializer < ApplicationSerializer
  private

  def serialize(reminder)
    {
      id: reminder.id,
      event_id: reminder.event_id,
      user_id: reminder.user_id,
      minutes_before: reminder.minutes_before
    }
  end
end
