require "test_helper"

class IcalFeedTokenTest < ActiveSupport::TestCase
  test "assigns a token on create" do
    token = IcalFeedToken.create!(user: users(:jane_admin))
    assert token.token.present?
  end

  test "regenerate! replaces the token" do
    token = IcalFeedToken.create!(user: users(:jane_admin))
    original = token.token

    token.regenerate!

    assert_not_equal original, token.token
  end

  test "webcal_url embeds the current token" do
    token = IcalFeedToken.create!(user: users(:jane_admin))
    assert_includes token.webcal_url, token.token
    assert token.webcal_url.start_with?("webcal://")
  end
end
