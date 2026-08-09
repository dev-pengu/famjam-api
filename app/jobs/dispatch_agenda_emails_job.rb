# Runs hourly (see config/recurring.yml) and sends any AgendaSubscription
# that's due today: matches the subscription's cadence (interval_days since
# anchor_date), fires once the current hour reaches the user's chosen
# send_hour_local (in their own resolved timezone), and hasn't already been
# sent today.
class DispatchAgendaEmailsJob < ApplicationJob
  queue_as :default

  AGENDA_WINDOW = 7.days

  def perform(now: Time.current)
    AgendaSubscription.where(enabled: true).includes(:user, :family).find_each do |subscription|
      next unless subscription.due?(now: now)
      next unless subscription.user.notifies_for?(:agenda_email)

      EventMailer.agenda_email(subscription: subscription, occurrences: occurrences_for(subscription)).deliver_now
      subscription.update!(last_sent_at: now)
    end
  end

  private

  def occurrences_for(subscription)
    range = Time.current..(Time.current + AGENDA_WINDOW)

    if subscription.mine?
      OccurrenceMaterializer.call(family: subscription.family, range: range, participant_person_id: subscription.user.person_id)
    else
      OccurrenceMaterializer.call(family: subscription.family, range: range)
    end
  end
end
