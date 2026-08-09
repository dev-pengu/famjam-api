class UpdateAgendaSubscriptionService < ApplicationService
  def initialize(subscription:, attributes:)
    @subscription = subscription
    @attributes = attributes
  end

  def call
    @subscription.update!(@attributes)
    ServiceResult.success(@subscription)
  rescue ActiveRecord::RecordInvalid => e
    ServiceResult.failure(e.record.errors.full_messages)
  end
end
