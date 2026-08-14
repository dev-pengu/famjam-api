module Api
  module V1
    class ChoreCompletionsController < ApplicationController
      before_action :set_family
      before_action :set_chore_completion, only: %i[approve reject]

      def index
        authorize Chore.new(family: @family), :index?, policy_class: ChorePolicy
        completions = @family.chore_completions.includes(:chore, completed_by_membership: :person)
        completions = completions.where(status: params[:status]) if ChoreCompletion.statuses.key?(params[:status])
        render json: ChoreCompletionSerializer.new(completions.order(created_at: :desc))
      end

      def approve
        authorize @chore_completion, :approve?
        result = ApproveChoreCompletionService.call(actor: current_user, chore_completion: @chore_completion)
        render_result(result, serializer: ChoreCompletionSerializer)
      end

      def reject
        authorize @chore_completion, :reject?
        contract = ChoreCompletionRejectParams.build(params)
        return render_invalid(contract) unless contract.valid?

        return render_invalid(@chore_completion) unless @chore_completion.reject(
          reviewed_by_user: current_user, reason: contract.reason,
        )

        render json: ChoreCompletionSerializer.new(@chore_completion)
      end

      private

      def set_family
        @family = current_user.families.find(params[:family_id])
      end

      def set_chore_completion
        @chore_completion = ChoreCompletion.joins(:chore).where(chores: { family_id: @family.id }).find(params[:id])
      end
    end
  end
end
