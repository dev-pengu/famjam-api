class NotificationPreferencesUpdateParams < ApplicationParams
  attribute :preferences, default: -> { [] }

  validate :preferences_valid

  def to_service_args
    { preferences: Array(preferences).map { |entry| entry.symbolize_keys.slice(:notification_type, :enabled) } }
  end

  private

  def preferences_valid
    entries = Array(preferences)
    return errors.add(:preferences, "can't be blank") if entries.empty?

    entries.each do |entry|
      type = entry.is_a?(Hash) ? (entry['notification_type'] || entry[:notification_type]) : nil
      errors.add(:preferences, "notification_type #{type.inspect} is not recognized") unless NotificationPreference.notification_types.key?(type.to_s)
    end
  end
end
