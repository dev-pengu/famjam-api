class DestroyEventReminderService < ApplicationService
  def initialize(event_reminder:)
    @event_reminder = event_reminder
  end

  def call
    @event_reminder.destroy!
    ServiceResult.success(true)
  end
end
