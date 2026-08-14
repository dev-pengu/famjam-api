class Reward < ApplicationRecord
  belongs_to :family
  belongs_to :created_by_user, class_name: "User"
  has_many :reward_redemptions, dependent: :destroy

  enum :status, { active: 0, archived: 1 }, default: :active

  validates :title, presence: true
  validates :coin_cost, presence: true, numericality: { greater_than: 0, only_integer: true }

  scope :active, -> { where(status: :active) }

  def archive
    update(status: :archived)
  end

  def request_redemption(claimee:, requested_at: Time.current)
    reward_redemptions.create(claimee: claimee, requested_at: requested_at)
  end
end
