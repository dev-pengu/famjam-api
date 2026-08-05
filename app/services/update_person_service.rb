class UpdatePersonService < ApplicationService
  def initialize(actor:, person:, attributes:)
    @actor = actor
    @person = person
    @attributes = attributes
  end

  def call
    previous_attributes = @person.attributes.slice('first_name', 'last_name', 'nickname')
    @person.update!(@attributes)

    AuditLogger.log(
      action: self_edit? ? 'person.self_updated' : 'person.updated',
      actor_user: @actor,
      family: relevant_family,
      target: @person,
      metadata: { previous: previous_attributes, updated: @attributes },
    )

    ServiceResult.success(@person)
  rescue ActiveRecord::RecordInvalid => e
    ServiceResult.failure(e.record.errors.full_messages)
  end

  private

  def self_edit?
    @person.id == @actor.person_id
  end

  def relevant_family
    return nil if self_edit?

    active_families = @person.memberships.active.map(&:family)
    active_families.first if active_families.size == 1
  end
end