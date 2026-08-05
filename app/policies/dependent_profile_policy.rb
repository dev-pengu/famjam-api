class DependentProfilePolicy < ApplicationPolicy
  # Owner, Admin, and Adult can all create a managed child profile.
  def create?
    owner? || admin? || adult?
  end

  def destroy?
    owner_or_admin? || guardian_of?(record.person)
  end

  def claim?
    record.person.managed? && (owner_or_admin? || guardian_of?(record.person))
  end
end