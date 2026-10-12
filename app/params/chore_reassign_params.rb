class ChoreReassignParams < ApplicationParams
  attribute :assignee_id, :string

  validates :assignee_id, presence: true, format: { with: UUID_REGEXP }
end
