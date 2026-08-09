class InvitationPolicy < ApplicationPolicy
  def index?
    owner_or_admin?
  end

  def create?
    owner_or_admin?
  end

  def revoke?
    owner_or_admin? && membership && record.family_id == membership.family_id
  end
end
