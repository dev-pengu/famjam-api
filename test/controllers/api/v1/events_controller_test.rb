require "test_helper"

class Api::V1::EventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @family = families(:smith_family)
    @event = events(:family_dinner)
  end

  test "index materializes the family's occurrences for an authenticated member" do
    get api_v1_family_events_url(@family), headers: auth_headers(users(:jane_admin)),
      params: { from: Time.current.iso8601, to: 1.week.from_now.iso8601 }
    assert_response :success
    event_ids = JSON.parse(response.body).map { |o| o["event"]["id"] }
    assert_includes event_ids, @event.id
  end

  test "index 404s for a non-member (family scoping happens before authorization)" do
    get api_v1_family_events_url(@family), headers: auth_headers(users(:pat_owner2))
    assert_response :not_found
  end

  test "create builds an event and its participants" do
    post api_v1_family_events_url(@family), headers: auth_headers(users(:jane_admin)), params: {
      title: "Piano Recital", timezone: "America/Chicago",
      starts_at: 3.days.from_now.iso8601, ends_at: 3.days.from_now.iso8601,
      participant_person_ids: [ people(:sam_child).id ]
    }

    assert_response :created
    body = JSON.parse(response.body)
    assert_equal "Piano Recital", body["title"]
    assert_equal [ people(:sam_child).id ], body["participants"].map { |p| p["id"] }
  end

  test "create is invalid without a title" do
    post api_v1_family_events_url(@family), headers: auth_headers(users(:jane_admin)), params: {
      timezone: "America/Chicago", starts_at: 3.days.from_now.iso8601, ends_at: 3.days.from_now.iso8601
    }

    assert_response :unprocessable_entity
  end

  test "update is forbidden for an adult with no relation to the event" do
    patch api_v1_family_event_url(@family, @event), headers: auth_headers(users(:morgan_adult)), params: {
      title: "Hijacked"
    }

    assert_response :forbidden
  end

  test "update succeeds for the family owner" do
    patch api_v1_family_event_url(@family, @event), headers: auth_headers(users(:lazaro_nixon)), params: {
      title: "Updated Family Dinner"
    }

    assert_response :success
    assert_equal "Updated Family Dinner", JSON.parse(response.body)["title"]
  end

  test "destroy succeeds for the creator" do
    assert_difference -> { @family.events.count }, -1 do
      delete api_v1_family_event_url(@family, @event), headers: auth_headers(users(:jane_admin))
    end
    assert_response :success
  end

  test "show 404s for an event in a different family" do
    other_family = families(:jones_family)
    get api_v1_family_event_url(other_family, @event), headers: auth_headers(users(:pat_owner2))
    assert_response :not_found
  end

  private

  def auth_headers(user)
    token = JwtService.encode_access_token(user_id: user.id)
    { "Authorization" => "Bearer #{token}", "X-Family-Id" => @family.id }
  end
end
