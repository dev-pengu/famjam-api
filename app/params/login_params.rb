class LoginParams < ApplicationParams
  attribute :email, :string
  attribute :password, :string
  attribute :device_name, :string

  validates :email, :password, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
end
