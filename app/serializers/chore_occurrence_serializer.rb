class ChoreOccurrenceSerializer < ApplicationSerializer
  private

  def serialize(occurrence)
    {
      due_on: occurrence.due_on,
      status: occurrence.status,
      series: occurrence.series?,
      chore: ChoreSerializer.new(occurrence.chore).as_json,
      completion: occurrence.completion && ChoreCompletionSerializer.new(occurrence.completion).as_json
    }
  end
end
