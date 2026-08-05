class AdminGrantService < ApplicationService
  def initialize(actor:, membership:)
    @actor = actor
    @membership = membership
  end

  def call
    previous_role = @membership.role
    @membership.update!(role: :admin)

    AuditLogger.log(
      action: 'member.role_changed',
      actor_user: @actor,
      family: @membership.family,
      target: @membership,
      metadata: { from: previous_role, to: 'admin' },
    )

    ServiceResult.success(@membership)
  end
end