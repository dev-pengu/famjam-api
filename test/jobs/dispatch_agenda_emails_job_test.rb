require "test_helper"

class DispatchAgendaEmailsJobTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup do
    @family = families(:smith_family)
    @user = users(:jane_admin)
    @subscription = AgendaSubscription.create!(user: @user, family: @family, scope: :mine, interval_days: 7, send_hour_local: 7)
    @tz = ActiveSupport::TimeZone[@user.display_timezone(family: @family)]
    @due_now = @tz.local(@subscription.anchor_date.year, @subscription.anchor_date.month, @subscription.anchor_date.day, 7)
  end

  test "sends and records last_sent_at when a subscription is due" do
    assert_emails 1 do
      DispatchAgendaEmailsJob.perform_now(now: @due_now)
    end

    assert_in_delta @due_now, @subscription.reload.last_sent_at, 1.second
  end

  test "does not send when not due" do
    not_due = @due_now + 1.day

    assert_no_emails do
      DispatchAgendaEmailsJob.perform_now(now: not_due)
    end
  end

  test "does not send when the subscription is disabled" do
    @subscription.update!(enabled: false)

    assert_no_emails do
      DispatchAgendaEmailsJob.perform_now(now: @due_now)
    end
  end

  test "does not send to a user who opted out of agenda emails" do
    @user.notification_preferences.create!(notification_type: :agenda_email, enabled: false)

    assert_no_emails do
      DispatchAgendaEmailsJob.perform_now(now: @due_now)
    end
  end
end
