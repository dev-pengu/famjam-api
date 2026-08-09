require "test_helper"

class EventTest < ActiveSupport::TestCase
  def valid_attributes
    {
      family: families(:smith_family),
      created_by_user: users(:jane_admin),
      title: "Soccer Practice",
      timezone: "America/Chicago",
      starts_at: 1.day.from_now,
      ends_at: 1.day.from_now + 1.hour
    }
  end

  test "valid with required attributes" do
    assert Event.new(valid_attributes).valid?
  end

  test "invalid without a title" do
    event = Event.new(valid_attributes.merge(title: nil))
    assert_not event.valid?
    assert_includes event.errors[:title], "can't be blank"
  end

  test "invalid without a timezone" do
    event = Event.new(valid_attributes.merge(timezone: nil))
    assert_not event.valid?
    assert_includes event.errors[:timezone], "can't be blank"
  end

  test "invalid with an unrecognized timezone" do
    event = Event.new(valid_attributes.merge(timezone: "Not/A_Zone"))
    assert_not event.valid?
    assert_includes event.errors[:timezone], "is not included in the list"
  end

  test "invalid when ends_at is before starts_at" do
    event = Event.new(valid_attributes.merge(starts_at: 1.day.from_now, ends_at: 1.day.from_now - 1.hour))
    assert_not event.valid?
    assert_includes event.errors[:ends_at], "must be on or after starts_at"
  end

  test "valid when ends_at equals starts_at" do
    same_time = 1.day.from_now
    event = Event.new(valid_attributes.merge(starts_at: same_time, ends_at: same_time))
    assert event.valid?
  end

  test "recurrence_byday is only valid for weekly recurrence" do
    event = Event.new(valid_attributes.merge(recurrence_frequency: :daily, recurrence_byday: [ "TU" ]))
    assert_not event.valid?
    assert_includes event.errors[:recurrence_byday], "is only valid for weekly recurrence"
  end

  test "recurrence_byday is valid for weekly recurrence" do
    event = Event.new(valid_attributes.merge(recurrence_frequency: :weekly, recurrence_byday: [ "TU" ]))
    assert event.valid?
  end

  test "recurring? reflects whether a recurrence_frequency is set" do
    assert_not Event.new(valid_attributes).recurring?
    assert Event.new(valid_attributes.merge(recurrence_frequency: :weekly)).recurring?
  end
end
