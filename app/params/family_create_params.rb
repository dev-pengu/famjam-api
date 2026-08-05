class FamilyCreateParams < ApplicationParams
  attribute :name, :string

  validates :name, presence: true, length: { maximum: 100 }
end
