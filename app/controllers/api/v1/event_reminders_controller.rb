module Api
  module V1
    class EventRemindersController < ApplicationController
      before_action :set_family
      before_action :set_event

      def index
        authorize @event, :show?, policy_class: EventPolicy
        render json: EventReminderSerializer.new(@event.event_reminders)
      end

      # A reminder with no user_id applies to every participant, and is
      # restricted to whoever can edit the event. A reminder with a user_id
      # is that user's own personal reminder/override, and any member who
      # can see the event may add one for themselves.
      def create
        contract = EventReminderCreateParams.build(params)
        return render_invalid(contract) unless contract.valid?

        if contract.user_id.present?
          authorize @event, :show?, policy_class: EventPolicy
          return render_forbidden(nil) unless contract.user_id == current_user.id
        else
          authorize @event, :manage_participants?, policy_class: EventPolicy
        end

        reminder = @event.event_reminders.create(minutes_before: contract.minutes_before, user_id: contract.user_id)
        return render_invalid(reminder) unless reminder.persisted?

        render json: EventReminderSerializer.new(reminder), status: :created
      end

      def destroy
        reminder = @event.event_reminders.find(params[:id])
        if reminder.user_id.present?
          authorize @event, :show?, policy_class: EventPolicy
          return render_forbidden(nil) unless reminder.user_id == current_user.id
        else
          authorize @event, :manage_participants?, policy_class: EventPolicy
        end

        reminder.destroy!
        render json: true
      end

      private

      def set_family
        @family = current_user.families.find(params[:family_id])
      end

      def set_event
        @event = @family.events.find(params[:event_id])
      end
    end
  end
end
