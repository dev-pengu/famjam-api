class PasswordResetConfirmParams < ApplicationParams
  attribute :token, :string
  attribute :password, :string

  validates :token, :password, presence: true
  validates :password, length: { minimum: 8, maximum: 128 }, allow_blank: true
end
