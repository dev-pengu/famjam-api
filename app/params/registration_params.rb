class RegistrationParams < ApplicationParams
  attribute :first_name, :string
  attribute :last_name, :string
  attribute :email, :string
  attribute :password, :string
  attribute :nickname, :string

  validates :first_name, :last_name, :email, :password, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :password, length: { minimum: 8, maximum: 128 }, allow_blank: true
end
