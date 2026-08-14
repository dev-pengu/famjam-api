module Api
  module V1
    class ChoresController < ApplicationController
      before_action :set_family
      before_action :set_chore, only: %i[update destroy complete]

      DEFAULT_INDEX_WINDOW = 6.days
      
      def index
        authorize Chore.new(family: @family), :index?
        occurrences = ChoreOccurrencesQuery.call(family: @family, range: index_range, assignee_id: params[:assignee_id])
        render json: ChoreOccurrenceSerializer.new(occurrences)
      end

      def create
        authorize Chore.new(family: @family), :create?
        contract = ChoreCreateParams.build(params)
        return render_invalid(contract) unless contract.valid?

        assignee = @family.memberships.find(contract.assignee_id)
        chore = @family.chores.create(
          created_by_user: current_user, assignee: assignee, **contract.to_service_args.except(:assignee_id),
        )
        return render_invalid(chore) unless chore.persisted?

        render json: ChoreSerializer.new(chore), status: :created
      end

      def update
        authorize @chore
        contract = ChoreUpdateParams.build(params)
        return render_invalid(contract) unless contract.valid?

        attrs = contract.to_service_args.compact
        attrs[:assignee] = @family.memberships.find(attrs.delete(:assignee_id)) if attrs[:assignee_id]

        return render_invalid(@chore) unless @chore.update(attrs)

        render json: ChoreSerializer.new(@chore)
      end

      def destroy
        authorize @chore, :archive?
        @chore.archive
        render json: ChoreSerializer.new(@chore)
      end

      def complete
        authorize @chore, :complete?
        contract = ChoreCompleteParams.build(params)
        return render_invalid(contract) unless contract.valid?

        completion = @chore.complete(completed_by_membership: @chore.assignee, due_on: contract.due_on)
        return render_invalid(completion) unless completion.persisted?

        render json: ChoreCompletionSerializer.new(completion), status: :created
      end

      private

      def set_family
        @family = current_user.families.find(params[:family_id])
      end

      def set_chore
        @chore = @family.chores.find(params[:id])
      end

      def index_range
        from = params[:from].present? ? Date.iso8601(params[:from]) : Date.current
        to = params[:to].present? ? Date.iso8601(params[:to]) : from + DEFAULT_INDEX_WINDOW
        from..to
      end
    end
  end
end
