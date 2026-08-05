class PasswordResetRequestParams < ApplicationParams
  attribute :email, :string

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
end
