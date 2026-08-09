class CreateEventService < ApplicationService
  def initialize(actor:, family:, title:, timezone:, starts_at:, ends_at:, description: nil, location: nil,
                  category: nil, all_day: false, include_all_family_members: false, participant_person_ids: [],
                  recurrence_frequency: nil, recurrence_interval: 1, recurrence_byday: [], recurrence_until: nil)
    @actor = actor
    @family = family
    @title = title
    @description = description
    @location = location
    @category = category
    @timezone = timezone
    @all_day = all_day
    @starts_at = starts_at
    @ends_at = ends_at
    @include_all_family_members = include_all_family_members
    @participant_person_ids = participant_person_ids
    @recurrence_frequency = recurrence_frequency
    @recurrence_interval = recurrence_interval
    @recurrence_byday = recurrence_byday
    @recurrence_until = recurrence_until
  end

  def call
    event = nil

    ActiveRecord::Base.transaction do
      event = @family.events.create!(
        created_by_user: @actor,
        title: @title,
        description: @description,
        location: @location,
        category: @category,
        timezone: @timezone,
        all_day: @all_day,
        starts_at: @starts_at,
        ends_at: @ends_at,
        recurrence_frequency: @recurrence_frequency,
        recurrence_interval: @recurrence_interval,
        recurrence_byday: @recurrence_byday,
        recurrence_until: @recurrence_until,
      )

      person_ids = EventParticipantIdsResolver.call(
        family: @family, participant_person_ids: @participant_person_ids,
        include_all_family_members: @include_all_family_members,
      )
      person_ids.each { |person_id| event.event_participants.create!(person_id: person_id) }
    end

    ServiceResult.success(event)
  rescue ActiveRecord::RecordInvalid => e
    ServiceResult.failure(e.record.errors.full_messages)
  end
end
