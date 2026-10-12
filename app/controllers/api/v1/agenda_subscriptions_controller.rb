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

        subscription = current_user.agenda_subscriptions.create(family: @family, **contract.to_service_args)
        return render_invalid(subscription) unless subscription.persisted?

        render json: AgendaSubscriptionSerializer.new(subscription), status: :created
      end

      def update
        subscription = current_user.agenda_subscriptions.find(params[:id])
        authorize subscription
        contract = AgendaSubscriptionUpdateParams.build(params)
        return render_invalid(contract) unless contract.valid?

        return render_invalid(subscription) unless subscription.update(contract.to_service_args)

        render json: AgendaSubscriptionSerializer.new(subscription)
      end

      def destroy
        subscription = current_user.agenda_subscriptions.find(params[:id])
        authorize subscription
        subscription.destroy!

        render json: true
      end

      private

      def set_family
        @family = current_user.families.find(params[:family_id])
      end
    end
  end
end
