# The single read-path for "what's due"
class ChoreOccurrencesQuery
  def self.call(family:, range:, assignee_id: nil, chore_id: nil)
    new(family: family, range: range, assignee_id: assignee_id, chore_id: chore_id).call
  end

  def initialize(family:, range:, assignee_id: nil, chore_id: nil)
    @family = family
    @range = range
    @assignee_id = assignee_id
    @chore_id = chore_id
  end

  def call
    occurrences = chores_scope.flat_map { |chore| occurrences_for(chore) }
    occurrences.sort_by(&:due_on)
  end

  private

  def chores_scope
    scope = @family.chores.active.includes(:chore_completions, assignee: :person)
    scope = scope.where(assignee_id: @assignee_id) if @assignee_id
    scope = scope.where(id: @chore_id) if @chore_id
    scope
  end

  def occurrences_for(chore)
    due_dates = chore.recurring? ? ChoreRecurrenceExpander.call(chore: chore, range: @range) : one_off_due_dates(chore)
    completions_by_due_on = chore.chore_completions.index_by(&:due_on)

    due_dates.map { |due_on| ChoreOccurrence.new(chore: chore, due_on: due_on, completion: completions_by_due_on[due_on]) }
  end

  def one_off_due_dates(chore)
    due_on = chore.starts_on.to_date
    @range.cover?(due_on) ? [ due_on ] : []
  end
end
