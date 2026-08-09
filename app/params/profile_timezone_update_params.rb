class ProfileTimezoneUpdateParams < ApplicationParams
  attribute :timezone, :string

  validates :timezone, presence: true, inclusion: { in: ActiveSupport::TimeZone::MAPPING.values }
end
