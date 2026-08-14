require "test_helper"

class Api::V1::RewardRedemptionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @family = families(:smith_family)
    @sam = memberships(:sam_child_smith)
    @sam.update!(coin_balance: 10)
    @reward = @family.rewards.create!(created_by_user: users(:lazaro_nixon), title: "Ice cream", coin_cost: 5)
    @redemption = @reward.request_redemption(claimee: @sam)
  end

  test "owner can list pending redemptions across the family" do
    get api_v1_family_reward_redemptions_url(@family),
      headers: auth_headers(users(:lazaro_nixon)), params: { status: "pending_approval" }

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal 1, body.length
    assert_equal @redemption.id, body.first["id"]
  end

  test "owner can approve a redemption, deducting coins" do
    post approve_api_v1_family_reward_redemption_url(@family, @redemption), headers: auth_headers(users(:lazaro_nixon))

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal "approved", body["status"]
    assert_equal 5, @sam.reload.coin_balance
  end

  test "a guardian can deny a redemption, with a reason" do
    post deny_api_v1_family_reward_redemption_url(@family, @redemption),
      headers: auth_headers(users(:alex_adult)), params: { reason: "Not this week" }

    assert_response :success
    assert_equal "denied", @redemption.reload.status
    assert_equal 10, @sam.reload.coin_balance
  end

  test "deny without a reason is rejected" do
    post deny_api_v1_family_reward_redemption_url(@family, @redemption), headers: auth_headers(users(:lazaro_nixon))

    assert_response :unprocessable_entity
  end

  test "an unrelated adult cannot approve or deny" do
    post approve_api_v1_family_reward_redemption_url(@family, @redemption), headers: auth_headers(users(:morgan_adult))
    assert_response :forbidden

    post deny_api_v1_family_reward_redemption_url(@family, @redemption),
      headers: auth_headers(users(:morgan_adult)), params: { reason: "no" }
    assert_response :forbidden
  end

  test "owner can cancel a pending redemption" do
    post cancel_api_v1_family_reward_redemption_url(@family, @redemption), headers: auth_headers(users(:lazaro_nixon))

    assert_response :success
    assert_equal "cancelled", @redemption.reload.status
  end

  test "cannot approve an already-cancelled redemption" do
    @redemption.cancel

    post approve_api_v1_family_reward_redemption_url(@family, @redemption), headers: auth_headers(users(:lazaro_nixon))

    assert_response :unprocessable_entity
  end

  private

  def auth_headers(user)
    token = JwtService.encode_access_token(user_id: user.id)
    { "Authorization" => "Bearer #{token}", "X-Family-Id" => @family.id }
  end
end
