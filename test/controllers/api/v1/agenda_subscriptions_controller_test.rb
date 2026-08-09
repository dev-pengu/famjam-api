require "test_helper"

class Api::V1::AgendaSubscriptionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @family = families(:smith_family)
  end

  test "create with defaults" do
    post api_v1_family_agenda_subscriptions_url(@family), headers: auth_headers(users(:jane_admin))

    assert_response :created
    body = JSON.parse(response.body)
    assert_equal "mine", body["scope"]
    assert_equal 7, body["interval_days"]
  end

  test "a user only sees their own subscriptions, not another member's" do
    AgendaSubscription.create!(user: users(:jane_admin), family: @family, scope: :mine)
    AgendaSubscription.create!(user: users(:alex_adult), family: @family, scope: :whole_family)

    get api_v1_family_agenda_subscriptions_url(@family), headers: auth_headers(users(:jane_admin))

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal 1, body.size
  end

  test "a user cannot update someone else's subscription" do
    subscription = AgendaSubscription.create!(user: users(:alex_adult), family: @family, scope: :mine)

    patch api_v1_family_agenda_subscription_url(@family, subscription), headers: auth_headers(users(:jane_admin)),
      params: { enabled: false }

    assert_response :not_found # scoped via current_user.agenda_subscriptions, so it's not even findable
  end

  test "a user can disable their own subscription" do
    subscription = AgendaSubscription.create!(user: users(:jane_admin), family: @family, scope: :mine)

    patch api_v1_family_agenda_subscription_url(@family, subscription), headers: auth_headers(users(:jane_admin)),
      params: { enabled: false }

    assert_response :success
    assert_not subscription.reload.enabled
  end

  test "a user can destroy their own subscription" do
    subscription = AgendaSubscription.create!(user: users(:jane_admin), family: @family, scope: :mine)

    delete api_v1_family_agenda_subscription_url(@family, subscription), headers: auth_headers(users(:jane_admin))

    assert_response :success
    assert_not AgendaSubscription.exists?(subscription.id)
  end

  private

  def auth_headers(user)
    token = JwtService.encode_access_token(user_id: user.id)
    { "Authorization" => "Bearer #{token}", "X-Family-Id" => @family.id }
  end
end
