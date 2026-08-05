class RemoveGuardianService < ApplicationService
  def initialize(actor:, guardianship:)
    @actor = actor
    @guardianship = guardianship
  end

  def call
    family = @guardianship.family
    metadata = {
      guardian_user_id: @guardianship.guardian_user_id,
      dependent_person_id: @guardianship.dependent_person_id,
    }

    @guardianship.destroy!

    AuditLogger.log(
      action: 'guardianship.removed',
      actor_user: @actor,
      family: family,
      metadata: metadata,
    )

    ServiceResult.success(true)
  end
end