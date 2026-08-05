class DependentCreateParams < ApplicationParams
  attribute :first_name, :string
  attribute :last_name, :string
  attribute :nickname, :string

  validates :first_name, :last_name, presence: true
end
