class EventParticipant < ApplicationRecord
  belongs_to :event
  belongs_to :person

  validates :person_id, uniqueness: { scope: :event_id }
end
