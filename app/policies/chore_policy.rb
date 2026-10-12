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

  # Can't complete a chore nobody has claimed yet - claim (or be assigned)
  # first.
  def complete?
    return false unless record.assignee

    owner_or_admin? || guardian_of?(record.assignee.person) || own_membership?
  end

  # Self-service only: any active member can claim an open chore for
  # themselves. A managed dependent (no login) can't call this themselves -
  # an Owner/Admin uses reassign? to hand it to them instead.
  def claim?
    record.unassigned? && membership.present?
  end

  # Owner/Admin can hand a chore (assigned or not) to any member - this is
  # also how a managed dependent, who can't self-claim, ends up assigned.
  def reassign?
    owner_or_admin?
  end

  def own_membership?
    record.assignee && record.assignee.person_id == context.user.person_id
  end
end
