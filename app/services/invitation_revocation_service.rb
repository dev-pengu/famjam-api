class InvitationRevocationService < ApplicationService
  def initialize(actor:, invitation:)
    @actor = actor
    @invitation = invitation
  end

  def call
    return ServiceResult.failure(['invitation already used or revoked']) unless @invitation.redeemable?

    @invitation.revoke!
    AuditLogger.log(
      action: 'invitation.revoked',
      actor_user: @actor,
      family: @invitation.family,
      target: @invitation,
    )

    ServiceResult.success(@invitation)
  end
end