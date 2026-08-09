class InvitationSerializer < ApplicationSerializer
  private

  def serialize(invitation)
    {
      id: invitation.id,
      code: invitation.code,
      role: invitation.role,
      email: invitation.email,
      expires_at: invitation.expires_at,
      revoked_at: invitation.revoked_at,
      used_at: invitation.used_at,
      redeemable: invitation.redeemable?,
      created_by_user_id: invitation.created_by_user_id,
      created_at: invitation.created_at
    }
  end
end
