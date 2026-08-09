class AgendaSubscriptionUpdateParams < ApplicationParams
  attribute :scope, :string
  attribute :interval_days, :integer
  attribute :send_hour_local, :integer
  attribute :enabled, :boolean

  validates :scope, inclusion: { in: AgendaSubscription.scopes.keys }, allow_nil: true
  validates :interval_days, numericality: { greater_than: 0 }, allow_nil: true
  validates :send_hour_local, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 23 }, allow_nil: true
  validate :at_least_one_field_present

  def any_changes?
    scope.present? || interval_days.present? || send_hour_local.present? || !enabled.nil?
  end

  def to_service_args
    super.compact
  end

  private

  def at_least_one_field_present
    errors.add(:base, "must include at least one field to update") unless any_changes?
  end
end
