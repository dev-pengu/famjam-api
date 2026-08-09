require "test_helper"

class Api::V1::MembershipsControllerSetColorTest < ActionDispatch::IntegrationTest
  setup do
    @family = families(:smith_family)
    @membership = memberships(:alex_adult_smith)
  end

  test "owner can set another member's color" do
    patch set_color_api_v1_family_membership_url(@family, @membership),
      headers: auth_headers(users(:lazaro_nixon)), params: { color: "teal" }

    assert_response :success
    assert_equal "teal", JSON.parse(response.body)["color"]
    assert_equal "teal", @membership.reload.color
  end

  test "an adult cannot set another member's color" do
    patch set_color_api_v1_family_membership_url(@family, @membership),
      headers: auth_headers(users(:morgan_adult)), params: { color: "teal" }

    assert_response :forbidden
  end

  test "rejects an unrecognized color" do
    patch set_color_api_v1_family_membership_url(@family, @membership),
      headers: auth_headers(users(:lazaro_nixon)), params: { color: "not_a_color" }

    assert_response :unprocessable_entity
  end

  private

  def auth_headers(user)
    token = JwtService.encode_access_token(user_id: user.id)
    { "Authorization" => "Bearer #{token}", "X-Family-Id" => @family.id }
  end
end
