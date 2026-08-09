class AdminRevocationService < ApplicationService
  def initialize(actor:, membership:)
    @actor = actor
    @membership = membership
  end

  def call
    @membership.update!(role: :adult)

    AuditLogger.log(
      action: "member.role_changed",
      actor_user: @actor,
      family: @membership.family,
      target: @membership,
      metadata: { from: "admin", to: "adult" },
    )

    ServiceResult.success(@membership)
  end
end
