class ChoreCompletionSerializer < ApplicationSerializer
  private

  def serialize(chore_completion)
    {
      id: chore_completion.id,
      chore_id: chore_completion.chore_id,
      due_on: chore_completion.due_on,
      completed_by_membership_id: chore_completion.completed_by_membership_id,
      completed_by: MembershipSerializer.new(chore_completion.completed_by_membership).as_json,
      completed_at: chore_completion.completed_at,
      coin_value: chore_completion.coin_value,
      status: chore_completion.status,
      reviewed_by_user_id: chore_completion.reviewed_by_user_id,
      reviewed_at: chore_completion.reviewed_at,
      rejection_reason: chore_completion.rejection_reason,
      coin_transaction_id: chore_completion.coin_transaction_id,
      created_at: chore_completion.created_at
    }
  end
end
