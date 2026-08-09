require "test_helper"

class Api::V1::ProfileControllerTest < ActionDispatch::IntegrationTest
  test "show includes the user's timezone and a resolved fallback" do
    get api_v1_profile_url, headers: auth_headers(users(:jane_admin))

    assert_response :success
    body = JSON.parse(response.body)
    assert_nil body["timezone"]
    assert_equal "UTC", body["resolved_timezone"]
  end

  test "PATCH timezone sets the user's own timezone preference" do
    patch timezone_api_v1_profile_url, headers: auth_headers(users(:jane_admin)), params: { timezone: "America/Chicago" }

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal "America/Chicago", body["timezone"]
    assert_equal "America/Chicago", users(:jane_admin).reload.timezone
  end

  test "PATCH timezone rejects an unrecognized timezone" do
    patch timezone_api_v1_profile_url, headers: auth_headers(users(:jane_admin)), params: { timezone: "Not/A_Zone" }

    assert_response :unprocessable_entity
  end

  private

  def auth_headers(user)
    token = JwtService.encode_access_token(user_id: user.id)
    { "Authorization" => "Bearer #{token}" }
  end
end
