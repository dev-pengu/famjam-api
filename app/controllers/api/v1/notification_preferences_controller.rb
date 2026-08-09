module Api
  module V1
    class NotificationPreferencesController < ApplicationController
      # Opt-out model: a missing row means enabled, so show resolves and
      # returns every type explicitly rather than only the rows that exist.
      def show
        preferences = NotificationPreference.notification_types.keys.map do |type|
          { notification_type: type, enabled: current_user.notifies_for?(type) }
        end
        render json: preferences
      end

      def update
        contract = NotificationPreferencesUpdateParams.build(params)
        return render_invalid(contract) unless contract.valid?

        result = UpdateNotificationPreferencesService.call(user: current_user, **contract.to_service_args)
        render_result(result, serializer: NotificationPreferenceSerializer)
      end
    end
  end
end
