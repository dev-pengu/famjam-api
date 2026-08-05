class InvitationCreationService < ApplicationService
  def initialize(actor:, family:, role:, email: nil, ttl_hours: nil)
    @actor = actor
    @family = family
    @role = role
    @email = email
    @ttl_hours = ttl_hours
  end

  def call
    invitation = @family.invitations.create!(
      role: @role,
      created_by_user: @actor,
      email: @email,
      expires_at: @ttl_hours ? @ttl_hours.hours.from_now : nil, # nil lets the model apply the family/app default
    )

    AuditLogger.log(
      action: 'invitation.created',
      actor_user: @actor,
      family: @family,
      target: invitation,
      metadata: { role: @role, email: @email, expires_at: invitation.expires_at },
    )

    ServiceResult.success(invitation)
  rescue ActiveRecord::RecordInvalid => e
    ServiceResult.failure(e.record.errors.full_messages)
  end
end