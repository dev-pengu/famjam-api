require "test_helper"

class Api::V1::RewardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @family = families(:smith_family)
    @sam = memberships(:sam_child_smith)
    @reward = @family.rewards.create!(created_by_user: users(:lazaro_nixon), title: "Ice cream", coin_cost: 5)
  end

  test "any member can list active rewards" do
    get api_v1_family_rewards_url(@family), headers: auth_headers(users(:alex_adult))

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal 1, body.length
    assert_equal "Ice cream", body.first["title"]
  end

  test "owner can create a reward" do
    post api_v1_family_rewards_url(@family), headers: auth_headers(users(:lazaro_nixon)), params: {
      title: "Movie night", coin_cost: 10
    }

    assert_response :created
    assert_equal "Movie night", JSON.parse(response.body)["title"]
  end

  test "an adult who isn't owner/admin cannot create a reward" do
    post api_v1_family_rewards_url(@family), headers: auth_headers(users(:morgan_adult)), params: {
      title: "Movie night", coin_cost: 10
    }

    assert_response :forbidden
  end

  test "owner can archive a reward" do
    delete api_v1_family_reward_url(@family, @reward), headers: auth_headers(users(:lazaro_nixon))

    assert_response :success
    assert_equal "archived", @reward.reload.status
  end

  test "a guardian can request a redemption on behalf of their dependent" do
    @sam.update!(coin_balance: 10)

    post request_redemption_api_v1_family_reward_url(@family, @reward),
      headers: auth_headers(users(:alex_adult)), params: { claimee_id: @sam.id }

    assert_response :created
    body = JSON.parse(response.body)
    assert_equal "pending_approval", body["status"]
    assert_equal @sam.id, body["claimee_id"]
  end

  test "a member can request a redemption for themselves without passing claimee_id" do
    alex = memberships(:alex_adult_smith)
    alex.update!(coin_balance: 10)

    post request_redemption_api_v1_family_reward_url(@family, @reward), headers: auth_headers(users(:alex_adult))

    assert_response :created
    assert_equal alex.id, JSON.parse(response.body)["claimee_id"]
  end

  test "requesting a redemption that exceeds balance fails cleanly" do
    post request_redemption_api_v1_family_reward_url(@family, @reward),
      headers: auth_headers(users(:alex_adult)), params: { claimee_id: @sam.id }

    assert_response :unprocessable_entity
  end

  test "an unrelated adult cannot request a redemption on behalf of another member" do
    post request_redemption_api_v1_family_reward_url(@family, @reward),
      headers: auth_headers(users(:morgan_adult)), params: { claimee_id: @sam.id }

    assert_response :forbidden
  end

  private

  def auth_headers(user)
    token = JwtService.encode_access_token(user_id: user.id)
    { "Authorization" => "Bearer #{token}", "X-Family-Id" => @family.id }
  end
end
