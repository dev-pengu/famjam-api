module Api
  module V1
    # Deliberately unauthenticated: external calendar apps (Apple/Google/
    # Outlook) poll this URL directly on their own schedule with no bearer
    # token, so the token itself (an opaque, revocable value baked into the
    # URL) is the only gate. 404 on an unknown/revoked token, not 401 - don't
    # hint at whether a given token ever existed.
    class IcalFeedsController < ApplicationController
      skip_before_action :authenticate_user!

      def show
        token = IcalFeedToken.find_by(token: params[:token])
        return render_not_found(nil) unless token

        render plain: IcalFeedGeneratorService.call(user: token.user), content_type: 'text/calendar'
      end
    end
  end
end
