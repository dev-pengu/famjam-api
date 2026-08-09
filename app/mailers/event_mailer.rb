class EventMailer < ApplicationMailer
  FRONTEND_BASE_URL = ENV.fetch('FRONTEND_BASE_URL', 'http://localhost:5173')

  def reminder_email(user:, event:, occurrence_start_at:, starts_at:, ends_at:, title:, location:)
    @user = user
    @event = event
    @occurrence_start_at = occurrence_start_at
    @starts_at = starts_at
    @ends_at = ends_at
    @title = title
    @location = location
    @display_timezone = user.display_timezone(family: event.family)
    @event_url = "#{FRONTEND_BASE_URL}/families/#{event.family_id}/calendar?event=#{event.id}"

    mail(to: user.email, subject: "Reminder: #{title}")
  end

  # occurrences is a plain Array<EventOccurrence> built by the caller
  # (DispatchAgendaEmailsJob) - this mailer is always invoked with
  # deliver_now from within that already-async job, never deliver_later,
  # since EventOccurrence is a PORO and isn't ActiveJob-serializable.
  def agenda_email(subscription:, occurrences:)
    @subscription = subscription
    @user = subscription.user
    @family = subscription.family
    @display_timezone = @user.display_timezone(family: @family)
    @occurrences = occurrences.reject(&:cancelled?).sort_by(&:starts_at)
    @whole_family = subscription.whole_family?

    mail(to: @user.email, subject: @whole_family ? "#{@family.name}'s upcoming agenda" : 'Your upcoming agenda')
  end
end
