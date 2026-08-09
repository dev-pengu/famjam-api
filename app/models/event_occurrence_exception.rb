class EventOccurrenceException < ApplicationRecord
  belongs_to :event
  belongs_to :created_by_user, class_name: "User"

  enum :status, { modified: 0, cancelled: 1 }
  enum :category, { school: 0, practice_sports: 1, medical: 2, travel: 3 }, prefix: true

  validates :occurrence_start_at, presence: true, uniqueness: { scope: :event_id }
end
