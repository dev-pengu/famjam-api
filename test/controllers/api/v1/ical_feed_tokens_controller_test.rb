require "test_helper"

class Api::V1::IcalFeedTokensControllerTest < ActionDispatch::IntegrationTest
  test "show 404s when the user has no token yet" do
    get api_v1_ical_feed_token_url, headers: auth_headers(users(:jane_admin))
    assert_response :not_found
  end

  test "create generates a token and returns its webcal_url" do
    post api_v1_ical_feed_token_url, headers: auth_headers(users(:jane_admin))

    assert_response :created
    body = JSON.parse(response.body)
    assert body["webcal_url"].start_with?("webcal://")
  end

  test "show returns the existing token's url once created" do
    post api_v1_ical_feed_token_url, headers: auth_headers(users(:jane_admin))

    get api_v1_ical_feed_token_url, headers: auth_headers(users(:jane_admin))
    assert_response :success
  end

  test "create regenerates (invalidates the old url) on a second call" do
    post api_v1_ical_feed_token_url, headers: auth_headers(users(:jane_admin))
    first_url = JSON.parse(response.body)["webcal_url"]

    post api_v1_ical_feed_token_url, headers: auth_headers(users(:jane_admin))
    second_url = JSON.parse(response.body)["webcal_url"]

    assert_not_equal first_url, second_url
  end

  private

  def auth_headers(user)
    token = JwtService.encode_access_token(user_id: user.id)
    { "Authorization" => "Bearer #{token}" }
  end
end
