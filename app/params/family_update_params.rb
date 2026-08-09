class FamilyUpdateParams < ApplicationParams
  attribute :name, :string
  attribute :invitation_ttl_hours, :integer
  attribute :default_timezone, :string

  validates :name, length: { maximum: 100 }, allow_nil: true
  validates :invitation_ttl_hours, numericality: { greater_than: 0, less_than_or_equal_to: 24 * 30 }, allow_nil: true
  validates :default_timezone, inclusion: { in: ActiveSupport::TimeZone::MAPPING.values }, allow_nil: true
  # No presence validations - a PATCH may touch just one field. Reject a
  # request that changes nothing rather than silently no-op-ing.
  validate :at_least_one_field_present

  def any_changes?
    name.present? || invitation_ttl_hours.present? || default_timezone.present?
  end

  def at_least_one_field_present
    errors.add(:base, "must include at least one field to update") unless any_changes?
  end
end
