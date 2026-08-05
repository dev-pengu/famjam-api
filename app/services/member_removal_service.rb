class MemberRemovalService < ApplicationService
  def initialize(actor:, membership:)
    @actor = actor
    @membership = membership
  end

  def call
    @membership.remove!
    AuditLogger.log(
      action: 'member.removed',
      actor_user: @actor,
      family: @membership.family,
      target: @membership,
      metadata: { removed_role: @membership.role },
    )
    ServiceResult.success(@membership)
  end
end
