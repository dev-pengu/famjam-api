class EventReminderCreateParams < ApplicationParams
  attribute :minutes_before, :integer
  attribute :user_id, :string

  validates :minutes_before, presence: true, numericality: { greater_than: 0 }
  validates :user_id, format: { with: UUID_REGEXP }, allow_nil: true
end
