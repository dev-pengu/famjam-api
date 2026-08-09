class EventParticipantCreateParams < ApplicationParams
  attribute :person_id, :string

  validates :person_id, presence: true, format: { with: UUID_REGEXP }
end
