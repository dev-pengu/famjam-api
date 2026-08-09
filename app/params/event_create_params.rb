class EventCreateParams < ApplicationParams
  attribute :title, :string
  attribute :description, :string
  attribute :location, :string
  attribute :category, :string
  attribute :timezone, :string
  attribute :all_day, :boolean, default: false
  attribute :starts_at, :datetime
  attribute :ends_at, :datetime
  attribute :include_all_family_members, :boolean, default: false
  attribute :participant_person_ids, default: -> { [] }
  attribute :recurrence_frequency, :string
  attribute :recurrence_interval, :integer, default: 1
  attribute :recurrence_byday, default: -> { [] }
  attribute :recurrence_until, :date

  validates :title, presence: true
  validates :timezone, presence: true
  validates :starts_at, :ends_at, presence: true
  validates :category, inclusion: { in: Event.categories.keys }, allow_nil: true
  validates :recurrence_frequency, inclusion: { in: Event.recurrence_frequencies.keys }, allow_nil: true
  validates :recurrence_interval, numericality: { greater_than: 0 }
end
