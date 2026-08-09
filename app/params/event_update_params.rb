class EventUpdateParams < ApplicationParams
  attribute :title, :string
  attribute :description, :string
  attribute :location, :string
  attribute :category, :string
  attribute :timezone, :string
  attribute :all_day, :boolean
  attribute :starts_at, :datetime
  attribute :ends_at, :datetime
  attribute :recurrence_frequency, :string
  attribute :recurrence_interval, :integer
  attribute :recurrence_byday
  attribute :recurrence_until, :date
  # No defaults on these two: nil means "the request didn't touch
  # participants," distinct from participant_person_ids: [] which means "set
  # it to no participants." UpdateEventService only reconciles participants
  # when at least one of these is actually present in the request.
  attribute :participant_person_ids
  attribute :include_all_family_members, :boolean

  validates :category, inclusion: { in: Event.categories.keys }, allow_nil: true
  validates :recurrence_frequency, inclusion: { in: Event.recurrence_frequencies.keys }, allow_nil: true
  validates :recurrence_interval, numericality: { greater_than: 0 }, allow_nil: true
  validate :at_least_one_field_present

  def any_changes?
    title.present? || description.present? || location.present? || category.present? ||
      timezone.present? || !all_day.nil? || starts_at.present? || ends_at.present? ||
      recurrence_frequency.present? || recurrence_interval.present? || recurrence_byday.present? ||
      recurrence_until.present? || !participant_person_ids.nil? || !include_all_family_members.nil?
  end

  def to_service_args
    super.compact
  end

  private

  def at_least_one_field_present
    errors.add(:base, "must include at least one field to update") unless any_changes?
  end
end
