class EmailVerificationParams < ApplicationParams
  attribute :token, :string

  validates :token, presence: true
end
