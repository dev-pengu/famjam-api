class IcalFeedTokenSerializer < ApplicationSerializer
  private

  def serialize(token)
    {
      id: token.id,
      webcal_url: token.webcal_url
    }
  end
end
