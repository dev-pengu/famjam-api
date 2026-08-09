require "test_helper"

class Api::V1::NotificationPreferencesControllerTest < ActionDispatch::IntegrationTest
  test "show returns every notification type, defaulting to enabled" do
    get api_v1_notification_preferences_url, headers: auth_headers(users(:jane_admin))

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal NotificationPreference.notification_types.keys.sort, body.map { |p| p["notification_type"] }.sort
    assert body.all? { |p| p["enabled"] }
  end

  test "update sets one or more preferences" do
    patch api_v1_notification_preferences_url, headers: auth_headers(users(:jane_admin)), params: {
      preferences: [
        { notification_type: "event_reminder", enabled: false },
        { notification_type: "agenda_email", enabled: false }
      ]
    }

    assert_response :success
    assert_not users(:jane_admin).notifies_for?(:event_reminder)
    assert_not users(:jane_admin).notifies_for?(:agenda_email)
    assert users(:jane_admin).notifies_for?(:event_invited) # untouched, still opt-out default
  end

  test "update rejects an unrecognized notification_type" do
    patch api_v1_notification_preferences_url, headers: auth_headers(users(:jane_admin)), params: {
      preferences: [ { notification_type: "not_a_real_type", enabled: false } ]
    }

    assert_response :unprocessable_entity
  end

  private

  def auth_headers(user)
    token = JwtService.encode_access_token(user_id: user.id)
    { "Authorization" => "Bearer #{token}" }
  end
end
