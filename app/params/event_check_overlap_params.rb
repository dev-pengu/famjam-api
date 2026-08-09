class EventCheckOverlapParams < ApplicationParams
  attribute :starts_at, :datetime
  attribute :ends_at, :datetime
  attribute :participant_person_ids, default: -> { [] }
  attribute :include_all_family_members, :boolean, default: false
  attribute :exclude_event_id, :string

  validates :starts_at, :ends_at, presence: true
end
