require "test_helper"

class Api::V1::CoinTransactionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @family = families(:smith_family)
    @membership = memberships(:sam_child_smith)
    AwardCoinsService.call(actor: users(:lazaro_nixon), membership: @membership, amount: 5, note: "Cleaned room")
    RedeemCoinsService.call(actor: users(:lazaro_nixon), membership: @membership, amount: 2, note: "Ice cream")
  end

  test "owner can list a member's coin transaction history" do
    get api_v1_family_membership_coin_transactions_url(@family, @membership),
      headers: auth_headers(users(:lazaro_nixon))

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal 2, body.length
    assert_equal(-2, body.first["amount"])
  end

  test "a guardian can list their dependent's coin transaction history" do
    get api_v1_family_membership_coin_transactions_url(@family, @membership),
      headers: auth_headers(users(:alex_adult))

    assert_response :success
  end

  test "an adult who isn't a guardian cannot list another member's coin transaction history" do
    get api_v1_family_membership_coin_transactions_url(@family, @membership),
      headers: auth_headers(users(:morgan_adult))

    assert_response :forbidden
  end

  test "a member can list their own coin transaction history" do
    get api_v1_family_membership_coin_transactions_url(@family, memberships(:alex_adult_smith)),
      headers: auth_headers(users(:alex_adult))

    assert_response :success
  end

  private

  def auth_headers(user)
    token = JwtService.encode_access_token(user_id: user.id)
    { "Authorization" => "Bearer #{token}", "X-Family-Id" => @family.id }
  end
end
