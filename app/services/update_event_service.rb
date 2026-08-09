class UpdateEventService < ApplicationService
  def initialize(event:, attributes:)
    @event = event
    @attributes = attributes.dup
    @participant_person_ids = @attributes.delete(:participant_person_ids)
    @include_all_family_members = @attributes.delete(:include_all_family_members)
  end

  def call
    ActiveRecord::Base.transaction do
      @event.update!(@attributes)
      reconcile_participants if touching_participants?
    end

    ServiceResult.success(@event)
  rescue ActiveRecord::RecordInvalid => e
    ServiceResult.failure(e.record.errors.full_messages)
  end

  private

  def touching_participants?
    !@participant_person_ids.nil? || !@include_all_family_members.nil?
  end

  def reconcile_participants
    target_ids = EventParticipantIdsResolver.call(
      family: @event.family, participant_person_ids: @participant_person_ids || [],
      include_all_family_members: @include_all_family_members || false,
    ).to_set

    current_ids = @event.people.ids.to_set

    (target_ids - current_ids).each { |person_id| @event.event_participants.create!(person_id: person_id) }
    @event.event_participants.where(person_id: (current_ids - target_ids).to_a).destroy_all
  end
end
