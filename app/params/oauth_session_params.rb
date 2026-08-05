class OauthSessionParams < ApplicationParams
  attribute :id_token, :string
  attribute :device_name, :string

  validates :id_token, presence: true
end
