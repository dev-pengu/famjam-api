module Api
  module V1
    class IcalFeedTokensController < ApplicationController
      def show
        token = current_user.ical_feed_token
        return render_not_found(nil) unless token

        render json: IcalFeedTokenSerializer.new(token)
      end

      # find_or_create the first time, regenerate (invalidating the old URL)
      # on subsequent calls - same "action verb" shape as claim/switch elsewhere.
      def create
        result = RegenerateIcalFeedTokenService.call(user: current_user)
        render_result(result, status: :created, serializer: IcalFeedTokenSerializer)
      end
    end
  end
end
