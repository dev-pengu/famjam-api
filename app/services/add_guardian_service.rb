class AddGuardianService < ApplicationService
  def initialize(actor:, family:, dependent_person:, guardian_user:)
    @actor = actor
    @family = family
    @dependent_person = dependent_person
    @guardian_user = guardian_user
  end

  def call
    guardianship = @family.guardianships.create!(
      guardian_user: @guardian_user, dependent_person: @dependent_person, created_by_user: @actor,
    )

    AuditLogger.log(
      action: "guardianship.added",
      actor_user: @actor,
      family: @family,
      target: guardianship,
      metadata: { guardian_user_id: @guardian_user.id, dependent_person_id: @dependent_person.id },
    )

    ServiceResult.success(guardianship)
  rescue ActiveRecord::RecordInvalid => e
    ServiceResult.failure(e.record.errors.full_messages)
  end
end
