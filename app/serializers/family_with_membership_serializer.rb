# Takes a Membership (not a Family) as input, since the whole point is
# pairing a family with the CURRENT USER's own role in it
class FamilyWithMembershipSerializer < ApplicationSerializer
  private

  def serialize(membership)
    FamilySerializer.new(membership.family).as_json.merge(
      membership: MembershipSerializer.new(membership).as_json,
    )
  end
end
