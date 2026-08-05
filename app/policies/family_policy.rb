class FamilyPolicy < ApplicationPolicy
  def show?
    membership.present?
  end

  # Editing name, invitation_ttl_hours, etc.
  def update?
    owner_or_admin?
  end

  def destroy?
    owner?
  end
end