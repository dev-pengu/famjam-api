class RegenerateIcalFeedTokenService < ApplicationService
  def initialize(user:)
    @user = user
  end

  def call
    token = @user.ical_feed_token
    token ? token.regenerate! : (token = @user.create_ical_feed_token!)

    ServiceResult.success(token)
  rescue ActiveRecord::RecordInvalid => e
    ServiceResult.failure(e.record.errors.full_messages)
  end
end
