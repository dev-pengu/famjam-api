class AccountLinkParams < ApplicationParams
  attribute :user_id, :string
  attribute :password, :string
  attribute :provider_uid, :string
  attribute :device_name, :string

  validates :user_id, presence: true, format: { with: UUID_REGEXP }
  validates :password, :provider_uid, presence: true
end
