class AgendaSubscription < ApplicationRecord
  belongs_to :user
  belongs_to :family

  enum :scope, { mine: 0, whole_family: 1 }

  validates :interval_days, numericality: { greater_than: 0 }
  validates :send_hour_local, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 23 }

  before_validation :set_anchor_date, on: :create

  # True once per due day: the current local hour matches send_hour_local,
  # the cadence (interval_days since anchor_date) lands on today, and it
  # hasn't already been sent today (defends against overlapping job runs).
  def due?(now: Time.current)
    return false unless enabled?

    local_now = now.in_time_zone(user.display_timezone(family: family))
    return false unless local_now.hour == send_hour_local
    return false if sent_today?(local_now)

    ((local_now.to_date - anchor_date).to_i % interval_days).zero?
  end

  private

  def sent_today?(local_now)
    return false unless last_sent_at

    last_sent_at.in_time_zone(user.display_timezone(family: family)).to_date == local_now.to_date
  end

  def set_anchor_date
    self.anchor_date ||= Date.current
  end
end
