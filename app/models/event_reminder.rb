class EventReminder < ApplicationRecord
  belongs_to :event
  belongs_to :user, optional: true

  has_many :event_reminder_deliveries, dependent: :destroy

  validates :minutes_before, numericality: { greater_than: 0 }
end
