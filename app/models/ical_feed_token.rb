class IcalFeedToken < ApplicationRecord
  belongs_to :user

  before_validation :assign_token, on: :create

  def regenerate!
    update!(token: generate_token)
  end

  def webcal_url
    host = ENV.fetch("API_BASE_URL", "http://localhost:3000").sub(%r{\Ahttps?://}, "")
    "webcal://#{host}/api/v1/ical/#{token}/feed.ics"
  end

  private

  def assign_token
    self.token ||= generate_token
  end

  def generate_token
    SecureRandom.urlsafe_base64(32)
  end
end
