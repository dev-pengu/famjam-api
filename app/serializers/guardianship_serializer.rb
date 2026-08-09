class GuardianshipSerializer < ApplicationSerializer
  private

  def serialize(guardianship)
    {
      id: guardianship.id,
      family_id: guardianship.family_id,
      created_at: guardianship.created_at,
      guardian: PersonSerializer.new(guardianship.guardian_user.person).as_json,
      dependent: PersonSerializer.new(guardianship.dependent_person).as_json
    }
  end
end
