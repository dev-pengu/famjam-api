class EventOccurrenceParams < ApplicationParams
  attribute :occurrence_start_at, :datetime
  attribute :title, :string
  attribute :description, :string
  attribute :location, :string
  attribute :category, :string
  attribute :starts_at, :datetime
  attribute :ends_at, :datetime

  validates :occurrence_start_at, presence: true
  validates :category, inclusion: { in: Event.categories.keys }, allow_nil: true

  def override_attributes
    { title:, description:, location:, category:, starts_at:, ends_at: }.compact
  end
end
