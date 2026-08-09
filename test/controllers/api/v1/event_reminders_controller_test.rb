require "test_helper"

class Api::V1::EventRemindersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @family = families(:smith_family)
    @event = events(:family_dinner) # created by jane_admin
  end

  test "the creator can create a blanket reminder for all participants" do
    post api_v1_family_event_reminders_url(@family, @event), headers: auth_headers(users(:jane_admin)),
      params: { minutes_before: 60 }

    assert_response :created
    body = JSON.parse(response.body)
    assert_nil body["user_id"]
    assert_equal 60, body["minutes_before"]
  end

  test "an unrelated adult cannot create a blanket reminder" do
    post api_v1_family_event_reminders_url(@family, @event), headers: auth_headers(users(:morgan_adult)),
      params: { minutes_before: 60 }

    assert_response :forbidden
  end

  test "any member who can see the event can create their own personal reminder" do
    post api_v1_family_event_reminders_url(@family, @event), headers: auth_headers(users(:morgan_adult)),
      params: { minutes_before: 15, user_id: users(:morgan_adult).id }

    assert_response :created
    assert_equal users(:morgan_adult).id, JSON.parse(response.body)["user_id"]
  end

  test "a member cannot create a personal reminder on behalf of someone else" do
    post api_v1_family_event_reminders_url(@family, @event), headers: auth_headers(users(:morgan_adult)),
      params: { minutes_before: 15, user_id: users(:alex_adult).id }

    assert_response :forbidden
  end

  test "a member can destroy their own personal reminder" do
    reminder = @event.event_reminders.create!(minutes_before: 15, user: users(:morgan_adult))

    delete api_v1_family_event_reminder_url(@family, @event, reminder), headers: auth_headers(users(:morgan_adult))
    assert_response :success
  end

  test "a member cannot destroy someone else's personal reminder" do
    reminder = @event.event_reminders.create!(minutes_before: 15, user: users(:alex_adult))

    delete api_v1_family_event_reminder_url(@family, @event, reminder), headers: auth_headers(users(:morgan_adult))
    assert_response :forbidden
  end

  private

  def auth_headers(user)
    token = JwtService.encode_access_token(user_id: user.id)
    { "Authorization" => "Bearer #{token}", "X-Family-Id" => @family.id }
  end
end
