class PersonSerializer < ApplicationSerializer
  private

  def serialize(person)
    payload = {
      id: person.id,
      first_name: person.first_name,
      last_name: person.last_name,
      nickname: person.nickname,
      display_name: person.display_name,
      managed: person.managed?,
    }

    payload[:guardians] = person.guardians.map { |guardian_user| PersonSerializer.new(guardian_user.person).as_json } if person.managed?
    payload[:guardianships] = person.guardianships.map { |guardianship| GuardianshipWithoutDependentSerializer.new(guardianship).as_json } if person.managed? 
    payload[:user_id] = person.user.id unless person.managed?

    payload
  end
end
