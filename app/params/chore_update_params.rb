class ChoreUpdateParams < ApplicationParams
  attribute :title, :string
  attribute :description, :string
  attribute :assignee_id, :string
  attribute :coin_value, :integer
  attribute :starts_on, :date
  attribute :recurrence_frequency, :string
  attribute :recurrence_interval, :integer
  attribute :recurrence_byday
  attribute :recurrence_until, :date

  validates :assignee_id, format: { with: UUID_REGEXP }, allow_nil: true
  validates :coin_value, numericality: { greater_than_or_equal_to: 0, only_integer: true }, allow_nil: true
  validates :recurrence_frequency, inclusion: { in: Chore.recurrence_frequencies.keys }, allow_nil: true
  validates :recurrence_interval, numericality: { greater_than: 0 }, allow_nil: true
  validate :at_least_one_field_present

  def any_changes?
    title.present? || description.present? || assignee_id.present? || coin_value.present? || starts_on.present? ||
      recurrence_frequency.present? || recurrence_interval.present? || recurrence_byday.present? || recurrence_until.present?
  end

  private

  def at_least_one_field_present
    errors.add(:base, "must include at least one field to update") unless any_changes?
  end
end
