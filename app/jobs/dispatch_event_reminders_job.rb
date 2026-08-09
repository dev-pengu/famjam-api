# Runs on a short interval (see config/recurring.yml) and sends any
# EventReminder that comes due within the run window. Dedupes sends via
# EventReminderDelivery so a reminder is never sent twice for the same
# (reminder, occurrence, user), even if the job overlaps a previous run.
class DispatchEventRemindersJob < ApplicationJob
  queue_as :default

  RUN_WINDOW = 5.minutes

  def perform(now: Time.current)
    due_window = now...(now + RUN_WINDOW)

    Event.joins(:event_reminders).distinct.find_each do |event|
      dispatch_for_event(event, now: now, due_window: due_window)
    end
  end

  private

  def dispatch_for_event(event, now:, due_window:)
    max_lead_minutes = event.event_reminders.maximum(:minutes_before)
    occurrence_range = now..(now + RUN_WINDOW + max_lead_minutes.minutes)

    occurrences = OccurrenceMaterializer.call(family: event.family, range: occurrence_range, event_id: event.id)
    occurrences.reject(&:cancelled?).each do |occurrence|
      event.event_reminders.each { |reminder| dispatch_reminder(reminder, occurrence, due_window: due_window) }
    end
  end

  def dispatch_reminder(reminder, occurrence, due_window:)
    remind_at = occurrence.starts_at - reminder.minutes_before.minutes
    return unless due_window.cover?(remind_at)

    recipients(reminder, occurrence).each do |user|
      next unless user.notifies_for?(:event_reminder)
      next if already_sent?(reminder, occurrence, user)

      EventMailer.reminder_email(
        user: user, event: occurrence.event, occurrence_start_at: occurrence.occurrence_start_at,
        starts_at: occurrence.starts_at, ends_at: occurrence.ends_at, title: occurrence.title,
        location: occurrence.location,
      ).deliver_later

      EventReminderDelivery.create!(
        event_reminder: reminder, occurrence_start_at: occurrence.occurrence_start_at, user: user, sent_at: Time.current,
      )
    end
  end

  # A reminder with a specific user is that user's own reminder/override.
  # A reminder with no user applies to every participant who has a login -
  # managed (no-login) children have no email to send to.
  def recipients(reminder, occurrence)
    return [ reminder.user ] if reminder.user_id.present?

    occurrence.event.people.filter_map(&:user)
  end

  def already_sent?(reminder, occurrence, user)
    EventReminderDelivery.exists?(event_reminder: reminder, occurrence_start_at: occurrence.occurrence_start_at, user: user)
  end
end
