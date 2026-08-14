require "test_helper"

class Api::V1::ChoreCompletionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @family = families(:smith_family)
    @sam = memberships(:sam_child_smith)
    @chore = @family.chores.create!(
      assignee: @sam, created_by_user: users(:lazaro_nixon), title: "Dishes", coin_value: 5, starts_on: Date.current,
    )
    @completion = @chore.complete(completed_by_membership: @sam, due_on: Date.current)
  end

  test "owner can list pending approvals across the family" do
    get api_v1_family_chore_completions_url(@family),
      headers: auth_headers(users(:lazaro_nixon)), params: { status: "pending_approval" }

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal 1, body.length
    assert_equal @completion.id, body.first["id"]
  end

  test "owner can approve a completion, awarding coins" do
    post approve_api_v1_family_chore_completion_url(@family, @completion), headers: auth_headers(users(:lazaro_nixon))

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal "approved", body["status"]
    assert_not_nil body["coin_transaction_id"]
    assert_equal 5, @sam.reload.coin_balance
  end

  test "a guardian can reject a completion, with a reason" do
    post reject_api_v1_family_chore_completion_url(@family, @completion),
      headers: auth_headers(users(:alex_adult)), params: { reason: "Not actually done" }

    assert_response :success
    assert_equal "rejected", @completion.reload.status
    assert_equal 0, @sam.reload.coin_balance
  end

  test "reject without a reason is rejected" do
    post reject_api_v1_family_chore_completion_url(@family, @completion), headers: auth_headers(users(:lazaro_nixon))

    assert_response :unprocessable_entity
  end

  test "an unrelated adult cannot approve" do
    post approve_api_v1_family_chore_completion_url(@family, @completion), headers: auth_headers(users(:morgan_adult))

    assert_response :forbidden
  end

  test "double approval does not double-award coins" do
    post approve_api_v1_family_chore_completion_url(@family, @completion), headers: auth_headers(users(:lazaro_nixon))
    post approve_api_v1_family_chore_completion_url(@family, @completion), headers: auth_headers(users(:lazaro_nixon))

    assert_response :unprocessable_entity
    assert_equal 5, @sam.reload.coin_balance
  end

  private

  def auth_headers(user)
    token = JwtService.encode_access_token(user_id: user.id)
    { "Authorization" => "Bearer #{token}", "X-Family-Id" => @family.id }
  end
end
