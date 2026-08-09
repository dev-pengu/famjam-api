require "test_helper"

class Api::V1::IcalFeedsControllerTest < ActionDispatch::IntegrationTest
  test "serves the calendar with no Authorization header at all" do
    token = IcalFeedToken.create!(user: users(:jane_admin))

    get api_v1_ical_feed_url(token: token.token) # deliberately no auth_headers - this endpoint is unauthenticated

    assert_response :success
    assert_equal "text/calendar", response.media_type
    assert_match "BEGIN:VCALENDAR", response.body
    assert_match "Family Dinner", response.body
  end

  test "404s on an unknown token" do
    get api_v1_ical_feed_url(token: "not-a-real-token")
    assert_response :not_found
  end

  test "404s on a revoked (regenerated) token" do
    token = IcalFeedToken.create!(user: users(:jane_admin))
    old_token = token.token
    token.regenerate!

    get api_v1_ical_feed_url(token: old_token)
    assert_response :not_found
  end
end
