class NotificationPreferenceSerializer < ApplicationSerializer
  private

  def serialize(preference)
    {
      id: preference.id,
      notification_type: preference.notification_type,
      enabled: preference.enabled
    }
  end
end
