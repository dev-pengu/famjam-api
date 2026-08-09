class EventReminderDelivery < ApplicationRecord
  belongs_to :event_reminder
  belongs_to :user

  validates :occurrence_start_at, presence: true
  validates :sent_at, presence: true
  validates :user_id, uniqueness: { scope: %i[event_reminder_id occurrence_start_at] }
end
