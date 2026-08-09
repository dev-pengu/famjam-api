require "test_helper"

class Api::V1::TimezonesControllerTest < ActionDispatch::IntegrationTest
  test "index returns every timezone accepted by Event/User/Family timezone fields" do
    get api_v1_timezones_url, headers: auth_headers(users(:jane_admin))

    assert_response :success
    body = JSON.parse(response.body)
    values = body.map { |tz| tz["value"] }

    assert_equal ActiveSupport::TimeZone::MAPPING.values.sort, values.sort
    assert_includes body, { "label" => "Central Time (US & Canada)", "value" => "America/Chicago" }
  end

  private

  def auth_headers(user)
    token = JwtService.encode_access_token(user_id: user.id)
    { "Authorization" => "Bearer #{token}" }
  end
end
