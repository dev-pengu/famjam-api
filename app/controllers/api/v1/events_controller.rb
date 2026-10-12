module Api
  module V1
    class EventsController < ApplicationController
      before_action :set_family
      before_action :set_event, only: %i[show update destroy occurrence]

      DEFAULT_INDEX_WINDOW = 3.months

      def index
        authorize Event.new(family: @family), :index?
        occurrences = OccurrenceMaterializer.call(family: @family, range: index_range)
        render json: EventOccurrenceSerializer.new(occurrences)
      end

      def show
        authorize @event
        render json: EventSerializer.new(@event)
      end

      def create
        authorize Event.new(family: @family), :create?
        contract = EventCreateParams.build(params)
        return render_invalid(contract) unless contract.valid?

        result = CreateEventService.call(actor: current_user, family: @family, **contract.to_service_args)
        return render_result(result) if result.failure?

        render json: event_payload_with_overlaps(result.data), status: :created
      end

      def update
        authorize @event
        contract = EventUpdateParams.build(params)
        return render_invalid(contract) unless contract.valid?

        result = UpdateEventService.call(event: @event, attributes: contract.to_service_args)
        return render_result(result) if result.failure?

        render json: event_payload_with_overlaps(result.data)
      end

      def destroy
        authorize @event
        @event.destroy!
        render json: true
      end

      # Pre-flight, non-blocking overlap check for the create/edit form -
      # takes the same shape as event create/update but persists nothing.
      def check_overlap
        authorize Event.new(family: @family), :check_overlap?
        contract = EventCheckOverlapParams.build(params)
        return render_invalid(contract) unless contract.valid?

        person_ids = EventParticipantIdsResolver.call(
          family: @family, participant_person_ids: contract.participant_person_ids,
          include_all_family_members: contract.include_all_family_members,
        )
        overlaps = OverlapChecker.call(
          family: @family, participant_person_ids: person_ids, starts_at: contract.starts_at,
          ends_at: contract.ends_at, exclude_event_id: contract.exclude_event_id,
        )
        render json: EventOccurrenceSerializer.new(overlaps)
      end

      # PATCH edits just this occurrence; DELETE cancels just this occurrence.
      # Editing/deleting the whole series uses the standard update/destroy
      # actions above instead.
      def occurrence
        authorize @event, :manage_occurrence?, policy_class: EventPolicy
        contract = EventOccurrenceParams.build(params)
        return render_invalid(contract) unless contract.valid?

        exception = EventOccurrenceException.upsert_for_occurrence(
          event: @event, occurrence_start_at: contract.occurrence_start_at,
          status: request.delete? ? :cancelled : :modified, actor: current_user, attributes: contract.override_attributes,
        )
        return render_invalid(exception) unless exception.errors.empty?

        render json: EventOccurrenceExceptionSerializer.new(exception)
      end

      private

      def set_family
        @family = current_user.families.find(params[:family_id])
      end

      def set_event
        @event = @family.events.find(params[:id])
      end

      def index_range
        from = params[:from].present? ? Time.iso8601(params[:from]) : Time.current
        to = params[:to].present? ? Time.iso8601(params[:to]) : from + DEFAULT_INDEX_WINDOW
        from..to
      end

      def event_payload_with_overlaps(event)
        overlaps = OverlapChecker.call(
          family: @family, participant_person_ids: event.people.ids, starts_at: event.starts_at,
          ends_at: event.ends_at, exclude_event_id: event.id,
        )
        EventSerializer.new(event).as_json.merge(overlaps: EventOccurrenceSerializer.new(overlaps).as_json)
      end
    end
  end
end
