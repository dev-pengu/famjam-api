module Api
  module V1
    # Reference data: the exact set of timezone identifiers accepted by
    # Event#timezone, User#timezone, and Family#default_timezone (all
    # validated against ActiveSupport::TimeZone::MAPPING.values). Exposed as
    # an endpoint rather than left for the frontend to hardcode, since a
    # duplicated copy of this list would silently drift from what the
    # backend actually accepts.
    class TimezonesController < ApplicationController
      def index
        timezones = ActiveSupport::TimeZone.all.map { |tz| { label: tz.name, value: tz.tzinfo.name } }
        render json: timezones
      end
    end
  end
end
