class AgendaSubscriptionCreateParams < ApplicationParams
  attribute :scope, :string, default: "mine"
  attribute :interval_days, :integer, default: 7
  attribute :send_hour_local, :integer, default: 7

  validates :scope, inclusion: { in: AgendaSubscription.scopes.keys }
  validates :interval_days, numericality: { greater_than: 0 }
  validates :send_hour_local, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 23 }
end
