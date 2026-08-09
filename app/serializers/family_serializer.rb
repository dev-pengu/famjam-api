class FamilySerializer < ApplicationSerializer
  private

  def serialize(family)
    {
      id: family.id,
      name: family.name,
      invitation_ttl_hours: family.invitation_ttl_hours,
      resolved_invitation_ttl_hours: family.invitation_ttl,
      default_timezone: family.default_timezone,
      resolved_timezone: family.timezone,
      created_at: family.created_at,
      owner: family.owner_membership.person,
      memberships: MembershipSerializer.new(family.memberships)
    }
  end
end
