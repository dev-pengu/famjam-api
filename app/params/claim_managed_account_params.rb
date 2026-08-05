class ClaimManagedAccountParams < ApplicationParams
  attribute :email, :string
  attribute :password, :string

  validates :email, :password, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :password, length: { minimum: 8, maximum: 128 }, allow_blank: true
end
