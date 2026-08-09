class RedeemCoinsParams < ApplicationParams
  attribute :amount, :integer
  attribute :note, :string

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :note, presence: true
end
