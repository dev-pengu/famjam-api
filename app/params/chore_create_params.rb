class ChoreCreateParams < ApplicationParams
  attribute :title, :string
  attribute :description, :string
  attribute :assignee_id, :string
  attribute :coin_value, :integer
  attribute :starts_on, :date
  attribute :recurrence_frequency, :string
  attribute :recurrence_interval, :integer, default: 1
  attribute :recurrence_byday, default: -> { [] }
  attribute :recurrence_until, :date

  validates :title, presence: true
  validates :assignee_id, presence: true, format: { with: UUID_REGEXP }
  validates :coin_value, presence: true, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :starts_on, presence: true
  validates :recurrence_frequency, inclusion: { in: Chore.recurrence_frequencies.keys }, allow_nil: true
  validates :recurrence_interval, numericality: { greater_than: 0 }
end
