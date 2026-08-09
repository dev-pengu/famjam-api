class NotificationPreference < ApplicationRecord
  belongs_to :user

  enum :notification_type, { event_reminder: 0, event_invited: 1, event_updated: 2, event_cancelled: 3,
                              agenda_email: 4 }

  validates :notification_type, uniqueness: { scope: :user_id }
end
