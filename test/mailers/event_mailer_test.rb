require "test_helper"

class EventMailerTest < ActionMailer::TestCase
  test "reminder_email" do
    user = users(:jane_admin)
    event = events(:family_dinner)

    mail = EventMailer.reminder_email(
      user: user, event: event, occurrence_start_at: event.starts_at, starts_at: event.starts_at,
      ends_at: event.ends_at, title: event.title, location: event.location,
    )

    assert_equal "Reminder: #{event.title}", mail.subject
    assert_equal [ user.email ], mail.to
    assert_match event.title, mail.text_part.body.to_s
    assert_match event.title, mail.html_part.body.to_s
  end

  test "agenda_email for a 'mine' subscription" do
    subscription = AgendaSubscription.create!(user: users(:jane_admin), family: families(:smith_family), scope: :mine)
    occurrence = OccurrenceMaterializer.call(family: families(:smith_family), range: Time.current..1.week.from_now).first

    mail = EventMailer.agenda_email(subscription: subscription, occurrences: [ occurrence ])

    assert_equal "Your upcoming agenda", mail.subject
    assert_equal [ users(:jane_admin).email ], mail.to
    assert_match occurrence.title, mail.text_part.body.to_s
  end

  test "agenda_email for a 'whole_family' subscription uses the family's name" do
    family = families(:smith_family)
    subscription = AgendaSubscription.create!(user: users(:jane_admin), family: family, scope: :whole_family)

    mail = EventMailer.agenda_email(subscription: subscription, occurrences: [])

    assert_equal "#{family.name}'s upcoming agenda", mail.subject
    assert_match "Nothing coming up", mail.text_part.body.to_s
  end
end
