require "test_helper"

class AgendaSubscriptionTest < ActiveSupport::TestCase
  def build_subscription(**overrides)
    AgendaSubscription.new({
      user: users(:jane_admin), family: families(:smith_family), interval_days: 7, send_hour_local: 7,
    }.merge(overrides))
  end

  test "anchor_date defaults to today on create" do
    subscription = build_subscription
    subscription.save!
    assert_equal Date.current, subscription.anchor_date
  end

  test "due? is false when disabled" do
    subscription = build_subscription(enabled: false)
    subscription.save!
    tz = ActiveSupport::TimeZone[subscription.user.display_timezone(family: subscription.family)]
    now = tz.local(subscription.anchor_date.year, subscription.anchor_date.month, subscription.anchor_date.day, 7)

    assert_not subscription.due?(now: now)
  end

  test "due? is true when the local hour matches and the cadence lands on today" do
    subscription = build_subscription(interval_days: 7, send_hour_local: 7)
    subscription.save!
    tz = ActiveSupport::TimeZone[subscription.user.display_timezone(family: subscription.family)]
    now = tz.local(subscription.anchor_date.year, subscription.anchor_date.month, subscription.anchor_date.day, 7)

    assert subscription.due?(now: now)
  end

  test "due? is false when the local hour doesn't match" do
    subscription = build_subscription(interval_days: 7, send_hour_local: 7)
    subscription.save!
    tz = ActiveSupport::TimeZone[subscription.user.display_timezone(family: subscription.family)]
    now = tz.local(subscription.anchor_date.year, subscription.anchor_date.month, subscription.anchor_date.day, 9)

    assert_not subscription.due?(now: now)
  end

  test "due? is false when the cadence hasn't landed on today" do
    subscription = build_subscription(interval_days: 7, send_hour_local: 7)
    subscription.save!
    tz = ActiveSupport::TimeZone[subscription.user.display_timezone(family: subscription.family)]
    now = tz.local(subscription.anchor_date.year, subscription.anchor_date.month, subscription.anchor_date.day, 7) + 2.days

    assert_not subscription.due?(now: now)
  end

  test "due? is false if already sent today" do
    subscription = build_subscription(interval_days: 7, send_hour_local: 7)
    subscription.save!
    tz = ActiveSupport::TimeZone[subscription.user.display_timezone(family: subscription.family)]
    now = tz.local(subscription.anchor_date.year, subscription.anchor_date.month, subscription.anchor_date.day, 7)
    subscription.update!(last_sent_at: now)

    assert_not subscription.due?(now: now)
  end
end
