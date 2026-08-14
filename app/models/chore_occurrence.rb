class ChoreOccurrence
  attr_reader :chore, :due_on, :completion

  def initialize(chore:, due_on:, completion: nil)
    @chore = chore
    @due_on = due_on
    @completion = completion
  end

  def status
    completion&.status || "outstanding"
  end

  def series? = chore.recurring?
end
