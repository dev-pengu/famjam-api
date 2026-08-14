require "test_helper"

class Api::V1::ChoresControllerTest < ActionDispatch::IntegrationTest
  setup do
    @family = families(:smith_family)
    @sam = memberships(:sam_child_smith)
  end

  test "index returns occurrences for the default window, embedding the chore" do
    chore = @family.chores.create!(
      assignee: @sam, created_by_user: users(:lazaro_nixon), title: "Dishes", coin_value: 5,
      starts_on: Date.current, recurrence_frequency: :daily, recurrence_interval: 1,
    )

    get api_v1_family_chores_url(@family), headers: auth_headers(users(:lazaro_nixon))

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal 7, body.length # today .. today+6
    assert_equal chore.id, body.first["chore"]["id"]
    assert_equal "outstanding", body.first["status"]
  end

  test "owner can create a chore" do
    post api_v1_family_chores_url(@family), headers: auth_headers(users(:lazaro_nixon)), params: {
      title: "Vacuum", assignee_id: @sam.id, coin_value: 3, starts_on: Date.current.iso8601
    }

    assert_response :created
    body = JSON.parse(response.body)
    assert_equal "Vacuum", body["title"]
    assert_equal @sam.id, body["assignee_id"]
  end

  test "an adult who isn't the owner/admin cannot create a chore" do
    post api_v1_family_chores_url(@family), headers: auth_headers(users(:morgan_adult)), params: {
      title: "Vacuum", assignee_id: @sam.id, coin_value: 3, starts_on: Date.current.iso8601
    }

    assert_response :forbidden
  end

  test "create rejects an assignee_id from another family" do
    post api_v1_family_chores_url(@family), headers: auth_headers(users(:lazaro_nixon)), params: {
      title: "Vacuum", assignee_id: memberships(:pat_owner2_jones).id, coin_value: 3, starts_on: Date.current.iso8601
    }

    assert_response :not_found
  end

  test "owner can update a chore" do
    chore = @family.chores.create!(
      assignee: @sam, created_by_user: users(:lazaro_nixon), title: "Dishes", coin_value: 5, starts_on: Date.current,
    )

    patch api_v1_family_chore_url(@family, chore), headers: auth_headers(users(:lazaro_nixon)), params: { coin_value: 10 }

    assert_response :success
    assert_equal 10, chore.reload.coin_value
  end

  test "owner can archive a chore" do
    chore = @family.chores.create!(
      assignee: @sam, created_by_user: users(:lazaro_nixon), title: "Dishes", coin_value: 5, starts_on: Date.current,
    )

    delete api_v1_family_chore_url(@family, chore), headers: auth_headers(users(:lazaro_nixon))

    assert_response :success
    assert_equal "archived", chore.reload.status
  end

  test "a guardian can complete a chore for their dependent" do
    chore = @family.chores.create!(
      assignee: @sam, created_by_user: users(:lazaro_nixon), title: "Dishes", coin_value: 5, starts_on: Date.current,
    )

    post complete_api_v1_family_chore_url(@family, chore),
      headers: auth_headers(users(:alex_adult)), params: { due_on: Date.current.iso8601 }

    assert_response :created
    body = JSON.parse(response.body)
    assert_equal "pending_approval", body["status"]
    assert_equal 5, body["coin_value"]
  end

  test "an adult who isn't a guardian cannot complete another member's chore" do
    chore = @family.chores.create!(
      assignee: @sam, created_by_user: users(:lazaro_nixon), title: "Dishes", coin_value: 5, starts_on: Date.current,
    )

    post complete_api_v1_family_chore_url(@family, chore),
      headers: auth_headers(users(:morgan_adult)), params: { due_on: Date.current.iso8601 }

    assert_response :forbidden
  end

  test "completing the same chore twice for the same due date fails cleanly" do
    chore = @family.chores.create!(
      assignee: @sam, created_by_user: users(:lazaro_nixon), title: "Dishes", coin_value: 5, starts_on: Date.current,
    )
    chore.complete(completed_by_membership: @sam, due_on: Date.current)

    post complete_api_v1_family_chore_url(@family, chore),
      headers: auth_headers(users(:lazaro_nixon)), params: { due_on: Date.current.iso8601 }

    assert_response :unprocessable_entity
  end

  private

  def auth_headers(user)
    token = JwtService.encode_access_token(user_id: user.id)
    { "Authorization" => "Bearer #{token}", "X-Family-Id" => @family.id }
  end
end
