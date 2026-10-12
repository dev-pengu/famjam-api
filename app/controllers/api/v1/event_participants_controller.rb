module Api
  module V1
    class EventParticipantsController < ApplicationController
      before_action :set_family
      before_action :set_event

      def create
        authorize @event, :manage_participants?, policy_class: EventPolicy
        contract = EventParticipantCreateParams.build(params)
        return render_invalid(contract) unless contract.valid?

        person = @family.people.find(contract.person_id)
        participant = @event.event_participants.create(person: person)
        return render_invalid(participant) unless participant.persisted?

        render json: EventParticipantSerializer.new(participant), status: :created
      end

      def destroy
        authorize @event, :manage_participants?, policy_class: EventPolicy
        participant = @event.event_participants.find(params[:id])
        participant.destroy!

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
