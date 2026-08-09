require "test_helper"

class Api::V1::FamiliesControllerTest < ActionDispatch::IntegrationTest
  test "show includes default_timezone and a resolved fallback" do
    family = families(:smith_family)

    get api_v1_family_url(family), headers: auth_headers(users(:jane_admin), family)

    assert_response :success
    body = JSON.parse(response.body)
    assert_nil body["default_timezone"]
    assert_equal "UTC", body["resolved_timezone"]
  end

  test "owner/admin can set the family's default_timezone" do
    family = families(:smith_family)

    patch api_v1_family_url(family), headers: auth_headers(users(:lazaro_nixon), family), params: {
      default_timezone: "America/Chicago",
    }

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal "America/Chicago", body["default_timezone"]
    assert_equal "America/Chicago", body["resolved_timezone"]
  end

  test "rejects an unrecognized default_timezone" do
    family = families(:smith_family)

    patch api_v1_family_url(family), headers: auth_headers(users(:lazaro_nixon), family), params: {
      default_timezone: "Not/A_Zone",
    }

    assert_response :unprocessable_entity
  end

  private

  def auth_headers(user, family)
    token = JwtService.encode_access_token(user_id: user.id)
    { "Authorization" => "Bearer #{token}", "X-Family-Id" => family.id }
  end
end
