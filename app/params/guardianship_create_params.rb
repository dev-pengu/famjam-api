class GuardianshipCreateParams < ApplicationParams
  attribute :dependent_person_id, :string
  attribute :guardian_user_id, :string

  validates :dependent_person_id, :guardian_user_id, presence: true, format: { with: UUID_REGEXP }
end
