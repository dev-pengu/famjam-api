class CreateEventReminderService < ApplicationService
  def initialize(event:, minutes_before:, user_id: nil)
    @event = event
    @minutes_before = minutes_before
    @user_id = user_id
  end

  def call
    reminder = @event.event_reminders.create!(minutes_before: @minutes_before, user_id: @user_id)
    ServiceResult.success(reminder)
  rescue ActiveRecord::RecordInvalid => e
    ServiceResult.failure(e.record.errors.full_messages)
  end
end
