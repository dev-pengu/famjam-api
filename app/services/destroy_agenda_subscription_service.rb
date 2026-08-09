class DestroyAgendaSubscriptionService < ApplicationService
  def initialize(subscription:)
    @subscription = subscription
  end

  def call
    @subscription.destroy!
    ServiceResult.success(true)
  end
end
