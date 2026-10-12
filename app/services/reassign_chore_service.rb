# Assigns a chore to a member - covers both "claim" (assignee: nil -> X) and
# "reassign" (assignee: A -> B) with the same logic, since mechanically
# they're the same operation just with a different starting assignee.
#
# A one-off chore is just updated in place - there's only ever one
# occurrence, so there's no history to protect.
#
# A recurring chore is NOT updated in place. Its completion history belongs
# to whoever actually did those chores under the old assignment, so instead
# this ends the existing series today (capping recurrence_until) and starts
# a brand new series - same title/description/coin_value/category/
# recurrence rule - assigned to the new member from today forward. The old
# chore is archived; its ChoreCompletions stay exactly where they are.
class ReassignChoreService < ApplicationService
  def initialize(actor:, chore:, new_assignee:)
    @actor = actor
    @chore = chore
    @new_assignee = new_assignee
  end

  def call
    if @chore.assignee_id == @new_assignee.id
      return ServiceResult.failure([ "chore is already assigned to this member" ])
    end

    @chore.recurring? ? split_and_reassign : reassign_in_place
  end

  private

  def reassign_in_place
    return ServiceResult.failure(@chore.errors.full_messages) unless @chore.update(assignee: @new_assignee)

    ServiceResult.success(@chore)
  end

  def split_and_reassign
    original_recurrence_until = @chore.recurrence_until
    new_chore = nil

    ActiveRecord::Base.transaction do
      cutoff = [ Date.current - 1, @chore.starts_on.to_date ].max
      @chore.update!(recurrence_until: cutoff, status: :archived)

      new_chore = @chore.family.chores.create!(
        assignee: @new_assignee, created_by_user: @actor, title: @chore.title, description: @chore.description,
        coin_value: @chore.coin_value, category: @chore.category, starts_on: Date.current,
        recurrence_frequency: @chore.recurrence_frequency, recurrence_interval: @chore.recurrence_interval,
        recurrence_byday: @chore.recurrence_byday, recurrence_until: original_recurrence_until,
      )
    end

    ServiceResult.success(new_chore)
  rescue ActiveRecord::RecordInvalid => e
    ServiceResult.failure(e.record.errors.full_messages)
  end
end
