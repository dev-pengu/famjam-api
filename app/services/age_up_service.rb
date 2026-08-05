class AgeUpService < ApplicationService
  def initialize(actor:, membership:)
    @actor = actor
    @membership = membership
  end

  def call
    @membership.update!(role: :adult)

    AuditLogger.log(
      action: 'member.aged_up',
      actor_user: @actor,
      family: @membership.family,
      target: @membership,
      metadata: { from: 'child', to: 'adult' },
    )

    ServiceResult.success(@membership)
  end
end