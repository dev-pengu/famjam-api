module Api
  module V1
    class AgendaSubscriptionsController < ApplicationController
      before_action :set_family

      def index
        authorize AgendaSubscription.new(family: @family), :index?
        render json: AgendaSubscriptionSerializer.new(current_user.agenda_subscriptions.where(family: @family))
      end

      def create
        authorize AgendaSubscription.new(family: @family, user: current_user), :create?
        contract = AgendaSubscriptionCreateParams.build(params)
        return render_invalid(contract) unless contract.valid?

        result = CreateAgendaSubscriptionService.call(user: current_user, family: @family, **contract.to_service_args)
        render_result(result, status: :created, serializer: AgendaSubscriptionSerializer)
      end

      def update
        subscription = current_user.agenda_subscriptions.find(params[:id])
        authorize subscription
        contract = AgendaSubscriptionUpdateParams.build(params)
        return render_invalid(contract) unless contract.valid?

        result = UpdateAgendaSubscriptionService.call(subscription: subscription, attributes: contract.to_service_args)
        render_result(result, serializer: AgendaSubscriptionSerializer)
      end

      def destroy
        subscription = current_user.agenda_subscriptions.find(params[:id])
        authorize subscription

        result = DestroyAgendaSubscriptionService.call(subscription: subscription)
        render_result(result)
      end

      private

      def set_family
        @family = current_user.families.find(params[:family_id])
      end
    end
  end
end
