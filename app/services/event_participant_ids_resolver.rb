# Shared by CreateEventService and the check_overlap pre-flight endpoint:
# resolves the set of person ids an event's participants should be, given
# explicit person ids plus an optional whole-family snapshot expansion.
#
# Whole-family participation is a snapshot of who's active right now, not a
# live/dynamic membership resolution - a family member added later is not
# retroactively added to an already-created whole-family event.
class EventParticipantIdsResolver
  def self.call(family:, participant_person_ids: [], include_all_family_members: false)
    person_ids = Array(participant_person_ids).to_set
    person_ids.merge(family.memberships.active.pluck(:person_id)) if include_all_family_members
    person_ids.to_a
  end
end
