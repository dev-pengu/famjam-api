class ApproveChoreCompletionService < ApplicationService
  def initialize(actor:, chore_completion:)
    @actor = actor
    @chore_completion = chore_completion
  end

  def call
    failure = nil

    ActiveRecord::Base.transaction do
      @chore_completion.lock!

      unless @chore_completion.pending_approval?
        failure = [ "Chore completion has already been reviewed" ]
        raise ActiveRecord::Rollback
      end

      award_result = AwardCoinsService.call(
        actor: @actor,
        membership: @chore_completion.completed_by_membership,
        amount: @chore_completion.coin_value,
        note: "Chore: #{@chore_completion.chore.title} (#{@chore_completion.due_on})",
      )

      if award_result.failure?
        failure = award_result.errors
        raise ActiveRecord::Rollback
      end

      @chore_completion.update!(
        status: :approved,
        reviewed_by_user: @actor,
        reviewed_at: Time.current,
        coin_transaction: award_result.data,
      )
    end

    failure ? ServiceResult.failure(failure) : ServiceResult.success(@chore_completion)
  rescue ActiveRecord::RecordInvalid => e
    ServiceResult.failure(e.record.errors.full_messages)
  end
end
