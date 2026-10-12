class ChoreCreateParams < ApplicationParams
  attribute :title, :string
  attribute :description, :string
  # Optional - omitted/nil means the chore starts out unassigned/open, for
  # any member to claim later.
  attribute :assignee_id, :string
  attribute :category, :string
  attribute :coin_value, :integer
  attribute :starts_on, :date
  attribute :recurrence_frequency, :string
  attribute :recurrence_interval, :integer, default: 1
  attribute :recurrence_byday, default: -> { [] }
  attribute :recurrence_until, :date

  validates :title, presence: true
  validates :assignee_id, format: { with: UUID_REGEXP }, allow_nil: true
  validates :category, inclusion: { in: Chore.categories.keys }, allow_nil: true
  validates :coin_value, presence: true, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :starts_on, presence: true
  validates :recurrence_frequency, inclusion: { in: Chore.recurrence_frequencies.keys }, allow_nil: true
  validates :recurrence_interval, numericality: { greater_than: 0 }
end
