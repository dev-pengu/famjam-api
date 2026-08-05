class Identity < ApplicationRecord
  belongs_to :user

  enum :provider, { google: 0 }

  validates :provider_uid, presence: true, uniqueness: { scope: :provider }
end
