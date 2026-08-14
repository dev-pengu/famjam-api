class RewardCreateParams < ApplicationParams
  attribute :title, :string
  attribute :description, :string
  attribute :coin_cost, :integer

  validates :title, presence: true
  validates :coin_cost, presence: true, numericality: { greater_than: 0, only_integer: true }
end
