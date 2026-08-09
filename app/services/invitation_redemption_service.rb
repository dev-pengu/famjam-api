class InvitationRedemptionService < ApplicationService
  def initialize(person:, code:, redeemer_email: nil)
    @person = person
    @code = code
    @redeemer_email = redeemer_email
  end

  def call
    invitation = Invitation.find_by(code: @code)
    return ServiceResult.failure([ "invitation code not found" ]) unless invitation
    return ServiceResult.failure([ "invitation has expired" ]) if invitation.expired?
    return ServiceResult.failure([ "invitation has already been used or revoked" ]) unless invitation.redeemable?

    if invitation.email.present? && invitation.email.casecmp(@redeemer_email.to_s).nonzero?
      return ServiceResult.failure([ "this invitation is restricted to a different email address" ])
    end

    membership = nil
    ActiveRecord::Base.transaction do
      invitation.redeem!(person: @person, redeemer_email: @redeemer_email)
      membership = @person.memberships.find_by(family: invitation.family)
    end

    AuditLogger.log(
      action: "invitation.redeemed",
      actor_user: @person.user,
      family: invitation.family,
      target: membership,
      metadata: { role: invitation.role },
    )

    ServiceResult.success(membership)
  rescue RuntimeError => e
    ServiceResult.failure([ e.message ])
  end
end
