require "test_helper"

class Api::V1::EventOccurrencesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @family = families(:smith_family)
    @event = Event.create!(
      family: @family, created_by_user: users(:jane_admin), title: "Practice", timezone: "America/Chicago",
      starts_at: 1.week.from_now, ends_at: 1.week.from_now + 1.hour, recurrence_frequency: :weekly,
      recurrence_interval: 1,
    )
    @occurrence_start_at = RecurrenceExpander.call(event: @event, range: Time.current..3.weeks.from_now).second
  end

  test "index materializes recurring occurrences within the requested range" do
    get api_v1_family_events_url(@family), headers: auth_headers(users(:jane_admin)),
      params: { from: Time.current.iso8601, to: 3.weeks.from_now.iso8601 }

    assert_response :success
    body = JSON.parse(response.body)
    practice_occurrences = body.select { |o| o["event"]["id"] == @event.id }
    assert_equal 3, practice_occurrences.size
  end

  test "PATCH occurrence edits just that occurrence, leaving the series and other occurrences untouched" do
    patch occurrence_api_v1_family_event_url(@family, @event), headers: auth_headers(users(:jane_admin)), params: {
      occurrence_start_at: @occurrence_start_at.iso8601, title: "Practice Moved to the Park"
    }

    assert_response :success
    assert_equal "Practice Moved to the Park", JSON.parse(response.body)["title"]
    assert_equal "Practice", @event.reload.title # the series title is untouched
  end

  test "DELETE occurrence cancels just that occurrence" do
    delete occurrence_api_v1_family_event_url(@family, @event), headers: auth_headers(users(:jane_admin)), params: {
      occurrence_start_at: @occurrence_start_at.iso8601
    }

    assert_response :success

    get api_v1_family_events_url(@family), headers: auth_headers(users(:jane_admin)),
      params: { from: Time.current.iso8601, to: 3.weeks.from_now.iso8601 }
    body = JSON.parse(response.body)
    practice_starts = body.select { |o| o["event"]["id"] == @event.id }.map { |o| o["occurrence_start_at"] }
    assert_not_includes practice_starts, @occurrence_start_at.iso8601
  end

  test "rejects an occurrence_start_at that doesn't correspond to a real occurrence" do
    patch occurrence_api_v1_family_event_url(@family, @event), headers: auth_headers(users(:jane_admin)), params: {
      occurrence_start_at: (@occurrence_start_at + 3.hours).iso8601, title: "Bogus"
    }

    assert_response :unprocessable_entity
  end

  test "an unrelated adult cannot edit an occurrence" do
    patch occurrence_api_v1_family_event_url(@family, @event), headers: auth_headers(users(:morgan_adult)), params: {
      occurrence_start_at: @occurrence_start_at.iso8601, title: "Hijacked"
    }

    assert_response :forbidden
  end

  private

  def auth_headers(user)
    token = JwtService.encode_access_token(user_id: user.id)
    { "Authorization" => "Bearer #{token}", "X-Family-Id" => @family.id }
  end
end
