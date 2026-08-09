class AgendaSubscriptionSerializer < ApplicationSerializer
  private

  def serialize(subscription)
    {
      id: subscription.id,
      family_id: subscription.family_id,
      scope: subscription.scope,
      interval_days: subscription.interval_days,
      send_hour_local: subscription.send_hour_local,
      anchor_date: subscription.anchor_date,
      enabled: subscription.enabled,
      last_sent_at: subscription.last_sent_at,
    }
  end
end
