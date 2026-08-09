require "test_helper"

class Api::V1::EventsControllerOverlapTest < ActionDispatch::IntegrationTest
  setup do
    @family = families(:smith_family)
    @existing = Event.create!(
      family: @family, created_by_user: users(:jane_admin), title: "Existing", timezone: "America/Chicago",
      starts_at: 3.days.from_now.change(hour: 17), ends_at: 3.days.from_now.change(hour: 18),
    )
    @existing.event_participants.create!(person: people(:alex_adult))
  end

  test "create surfaces (but does not block on) an overlap for a shared participant" do
    post api_v1_family_events_url(@family), headers: auth_headers(users(:jane_admin)), params: {
      title: "New Overlapping Event", timezone: "America/Chicago",
      starts_at: 3.days.from_now.change(hour: 17, min: 30).iso8601,
      ends_at: 3.days.from_now.change(hour: 18, min: 30).iso8601,
      participant_person_ids: [people(:alex_adult).id],
    }

    assert_response :created # non-blocking: still succeeds
    body = JSON.parse(response.body)
    assert_equal 1, body["overlaps"].size
    assert_equal @existing.id, body["overlaps"].first["event"]["id"]
  end

  test "check_overlap reports conflicts without creating anything" do
    assert_no_difference -> { Event.count } do
      post check_overlap_api_v1_family_events_url(@family), headers: auth_headers(users(:jane_admin)), params: {
        starts_at: 3.days.from_now.change(hour: 17, min: 30).iso8601,
        ends_at: 3.days.from_now.change(hour: 18, min: 30).iso8601,
        participant_person_ids: [people(:alex_adult).id],
      }
    end

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal 1, body.size
    assert_equal @existing.id, body.first["event"]["id"]
  end

  test "check_overlap returns nothing for a non-conflicting time" do
    post check_overlap_api_v1_family_events_url(@family), headers: auth_headers(users(:jane_admin)), params: {
      starts_at: 10.days.from_now.iso8601, ends_at: (10.days.from_now + 1.hour).iso8601,
      participant_person_ids: [people(:alex_adult).id],
    }

    assert_response :success
    assert_empty JSON.parse(response.body)
  end

  private

  def auth_headers(user)
    token = JwtService.encode_access_token(user_id: user.id)
    { "Authorization" => "Bearer #{token}", "X-Family-Id" => @family.id }
  end
end
