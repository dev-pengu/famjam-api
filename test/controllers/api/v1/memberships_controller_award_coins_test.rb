require "test_helper"

class Api::V1::MembershipsControllerAwardCoinsTest < ActionDispatch::IntegrationTest
  setup do
    @family = families(:smith_family)
    @membership = memberships(:sam_child_smith)
  end

  test "owner can award coins to a member" do
    post award_coins_api_v1_family_membership_url(@family, @membership),
      headers: auth_headers(users(:lazaro_nixon)), params: { amount: 5, note: "Cleaned room" }

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal 5, body["amount"]
    assert_equal 5, body["balance_after"]
    assert_equal 5, @membership.reload.coin_balance
  end

  test "a guardian can award coins to their dependent" do
    post award_coins_api_v1_family_membership_url(@family, @membership),
      headers: auth_headers(users(:alex_adult)), params: { amount: 3 }

    assert_response :success
    assert_equal 3, @membership.reload.coin_balance
  end

  test "an adult who isn't a guardian cannot award coins" do
    post award_coins_api_v1_family_membership_url(@family, @membership),
      headers: auth_headers(users(:morgan_adult)), params: { amount: 3 }

    assert_response :forbidden
  end

  test "rejects a non-positive amount" do
    post award_coins_api_v1_family_membership_url(@family, @membership),
      headers: auth_headers(users(:lazaro_nixon)), params: { amount: 0 }

    assert_response :unprocessable_entity
  end

  private

  def auth_headers(user)
    token = JwtService.encode_access_token(user_id: user.id)
    { "Authorization" => "Bearer #{token}", "X-Family-Id" => @family.id }
  end
end
