class EventParticipantIdsResolver
  def self.call(family:, participant_person_ids: [], include_all_family_members: false)
    person_ids = Array(participant_person_ids).to_set
    person_ids.merge(family.memberships.active.pluck(:person_id)) if include_all_family_members
    person_ids.to_a
  end
end
