class RewardRedemptionPolicy < ApplicationPolicy
  def request_redemption?
    owner_or_admin? || guardian_of?(record.claimee.person) || own_membership?
  end

  def approve?
    owner_or_admin? || guardian_of?(record.claimee.person)
  end

  def deny?
    owner_or_admin? || guardian_of?(record.claimee.person)
  end

  def cancel?
    owner_or_admin? || own_membership?
  end

  def own_membership?
    record.claimee.person_id == context.user.person_id
  end
end
