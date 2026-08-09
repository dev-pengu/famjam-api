class CreateAgendaSubscriptionService < ApplicationService
  def initialize(user:, family:, scope:, interval_days:, send_hour_local:)
    @user = user
    @family = family
    @scope = scope
    @interval_days = interval_days
    @send_hour_local = send_hour_local
  end

  def call
    subscription = @user.agenda_subscriptions.create!(
      family: @family, scope: @scope, interval_days: @interval_days, send_hour_local: @send_hour_local,
    )
    ServiceResult.success(subscription)
  rescue ActiveRecord::RecordInvalid => e
    ServiceResult.failure(e.record.errors.full_messages)
  end
end
