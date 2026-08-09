class PersonPolicy < ApplicationPolicy
  def update?
    return false unless context.user

    editing_own_profile? || authorized_to_edit_dependent?
  end

  private

  def editing_own_profile?
    record.id == context.user.person_id
  end

  # A managed (no-login) dependent can be edited by:
  #   - an Owner/Admin in any family the dependent is an active member of, or
  #   - a registered guardian of that dependent, in any family
  def authorized_to_edit_dependent?
    return false unless record.managed?

    family_ids = record.memberships.active.pluck(:family_id)
    return false if family_ids.empty?

    owner_or_admin_in_any_of?(family_ids) || context.user.guardianships.exists?(dependent_person_id: record.id)
  end

  def owner_or_admin_in_any_of?(family_ids)
    context.user.memberships.active.where(role: %i[owner admin], family_id: family_ids).exists?
  end
end
