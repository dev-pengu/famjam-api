class MembershipPolicy < ApplicationPolicy
  def index?
    membership.present?
  end

  # Owner can remove anyone except themselves (they must transfer first).
  # Admin can remove Adults and Children, but not the Owner or other Admins.
  def remove?
    return false unless owner_or_admin?
    return false if record.role == 'owner'
    return true if owner?

    admin? && record.role.in?(%w[adult child])
  end

  # Self-service leave. Owner cannot leave directly — must transfer ownership
  # first, at which point their own membership row is no longer role: owner.
  def leave?
    record.person_id == context.user.person_id && record.role != 'owner'
  end

  def grant_admin?
    owner? && record.role == 'adult'
  end

  def revoke_admin?
    owner? && record.role == 'admin'
  end

  # Ownership transfer: target must currently be admin or adult, and can't be
  # the acting owner's own membership (that's a no-op).
  def transfer_ownership?
    owner? && record.role.in?(%w[admin adult]) && record.id != membership&.id
  end

  def age_up?
    owner_or_admin? && record.role == 'child'
  end

  def reactivate?
    return false if record.active?
    return false if record.role == 'owner'

    owner? || (amdin? && record.role.in?(%w[adult child]))
  end

  def view_former?
    owner_or_admin?
  end
end