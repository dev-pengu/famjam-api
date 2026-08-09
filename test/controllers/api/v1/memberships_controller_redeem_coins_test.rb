require "test_helper"

class Api::V1::MembershipsControllerRedeemCoinsTest < ActionDispatch::IntegrationTest
  setup do
    @family = families(:smith_family)
    @membership = memberships(:sam_child_smith)
    @membership.update!(coin_balance: 10)
  end

  test "owner can redeem coins for a member" do
    post redeem_coins_api_v1_family_membership_url(@family, @membership),
      headers: auth_headers(users(:lazaro_nixon)), params: { amount: 4, note: "Ice cream trip" }

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal(-4, body["amount"])
    assert_equal 6, body["balance_after"]
    assert_equal 6, @membership.reload.coin_balance
  end

  test "a guardian can redeem coins for their dependent" do
    post redeem_coins_api_v1_family_membership_url(@family, @membership),
      headers: auth_headers(users(:alex_adult)), params: { amount: 4, note: "Ice cream trip" }

    assert_response :success
    assert_equal 6, @membership.reload.coin_balance
  end

  test "an adult who isn't a guardian cannot redeem coins" do
    post redeem_coins_api_v1_family_membership_url(@family, @membership),
      headers: auth_headers(users(:morgan_adult)), params: { amount: 4, note: "Ice cream trip" }

    assert_response :forbidden
  end

  test "rejects redemption without a note" do
    post redeem_coins_api_v1_family_membership_url(@family, @membership),
      headers: auth_headers(users(:lazaro_nixon)), params: { amount: 4 }

    assert_response :unprocessable_entity
  end

  test "rejects redemption that exceeds the balance" do
    post redeem_coins_api_v1_family_membership_url(@family, @membership),
      headers: auth_headers(users(:lazaro_nixon)), params: { amount: 100, note: "Too much" }

    assert_response :unprocessable_entity
    assert_equal 10, @membership.reload.coin_balance
  end

  private

  def auth_headers(user)
    token = JwtService.encode_access_token(user_id: user.id)
    { "Authorization" => "Bearer #{token}", "X-Family-Id" => @family.id }
  end
end
