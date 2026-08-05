class ChangePasswordParams < ApplicationParams
  attribute :current_password, :string
  attribute :new_password, :string
  attribute :device_name, :string

  validates :current_password, :new_password, presence: true
  validates :new_password, length: { minimum: 10, maximum: 128 }, allow_blank: true
end
