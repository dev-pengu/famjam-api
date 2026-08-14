class ChoreCompletionPolicy < ApplicationPolicy
  def approve?
    owner_or_admin? || guardian_of?(record.completed_by_membership.person)
  end

  def reject?
    owner_or_admin? || guardian_of?(record.completed_by_membership.person)
  end
end
