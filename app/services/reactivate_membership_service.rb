# This is the ONLY way to bring a managed dependent back into a family -
# they have no login and therefore no way to redeem an invitation
# themselves. For a full user, an Owner/Admin can use either this (direct,
# no invite code needed) or InvitationRedemptionService (self-service, via
# a code the person redeems themselves).
class ReactivateMembershipService < ApplicationService
  def initialize(actor:, membership:, role: nil)
    @actor = actor
    @membership = membership
    @role = role
  end

  def call
    return ServiceResult.failure([ "membership is already active" ]) if @membership.active?

    previous_role = @membership.role
    @membership.reactivate!(role: @role, invited_by_user: @actor)

    AuditLogger.log(
      action: "member.reactivated",
      actor_user: @actor,
      family: @membership.family,
      target: @membership,
      metadata: { previous_role: previous_role, new_role: @membership.role },
    )

    ServiceResult.success(@membership)
  rescue ActiveRecord::RecordInvalid => e
    ServiceResult.failure(e.record.errors.full_messages)
  end
end
