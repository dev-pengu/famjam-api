# Informational, non-blocking check: does a candidate event time overlap
# with any existing occurrence for any of the given participants? Used both
# after create/update (surfaced alongside the saved event) and by a
# dedicated pre-flight endpoint so the frontend can warn before the user
# even submits the form.
class OverlapChecker
  def self.call(family:, participant_person_ids:, starts_at:, ends_at:, exclude_event_id: nil)
    new(family: family, participant_person_ids: participant_person_ids, starts_at: starts_at, ends_at: ends_at,
        exclude_event_id: exclude_event_id).call
  end

  def initialize(family:, participant_person_ids:, starts_at:, ends_at:, exclude_event_id: nil)
    @family = family
    @participant_person_ids = Array(participant_person_ids)
    @starts_at = starts_at
    @ends_at = ends_at
    @exclude_event_id = exclude_event_id
  end

  def call
    return [] if @participant_person_ids.empty?

    candidate_occurrences
      .select { |occurrence| overlaps?(occurrence) && occurrence.event.id != @exclude_event_id }
      .sort_by(&:starts_at)
  end

  private

  def candidate_occurrences
    @participant_person_ids.flat_map do |person_id|
      OccurrenceMaterializer.call(family: @family, range: @starts_at..@ends_at, participant_person_id: person_id)
    end.uniq { |occurrence| [ occurrence.event.id, occurrence.occurrence_start_at ] }
  end

  def overlaps?(occurrence)
    occurrence.starts_at < @ends_at && occurrence.ends_at > @starts_at
  end
end
