class MembershipSerializer < ApplicationSerializer
  private

  def serialize(membership)
    {
      id: membership.id,
      family_id: membership.family_id,
      role: membership.role,
      status: membership.status,
      joined_at: membership.joined_at,
      left_at: membership.left_at,
      removed_at: membership.removed_at,
      person: PersonSerializer.new(membership.person).as_json,
    }
  end
end