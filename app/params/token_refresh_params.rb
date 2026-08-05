class TokenRefreshParams < ApplicationParams
  attribute :refresh_token, :string
  attribute :device_name, :string

  validates :refresh_token, presence: true
end
