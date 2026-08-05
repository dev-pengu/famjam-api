class GuardianshipPolicy < ApplicationPolicy
  def create?
    owner_or_admin? || guardian_of?(record.dependent_person)
  end

  def destroy?
    owner_or_admin? || guardian_of?(record.dependent_person)
  end
end
