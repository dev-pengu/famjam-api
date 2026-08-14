class ChoreCompleteParams < ApplicationParams
  attribute :due_on, :date

  validates :due_on, presence: true
end
