class ChorePolicy < ApplicationPolicy
  def index?
    membership.present?
  end

  def create?
    owner_or_admin?
  end

  def update?
    owner_or_admin?
  end

  def archive?
    owner_or_admin?
  end

  def complete?
    owner_or_admin? || guardian_of?(record.assignee.person) || own_membership?
  end

  def own_membership?
    record.assignee.person_id == context.user.person_id
  end
end
