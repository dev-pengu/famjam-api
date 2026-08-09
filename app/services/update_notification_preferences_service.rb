class UpdateNotificationPreferencesService < ApplicationService
  def initialize(user:, preferences:)
    @user = user
    @preferences = preferences
  end

  def call
    records = @preferences.map do |entry|
      preference = @user.notification_preferences.find_or_initialize_by(notification_type: entry[:notification_type])
      preference.update!(enabled: ActiveModel::Type::Boolean.new.cast(entry[:enabled]))
      preference
    end

    ServiceResult.success(records)
  rescue ActiveRecord::RecordInvalid => e
    ServiceResult.failure(e.record.errors.full_messages)
  end
end
