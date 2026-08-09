class EventPolicy < ApplicationPolicy
  def index?
    membership.present?
  end

  def show?
    membership.present? && record.family_id == membership.family_id
  end

  def create?
    membership.present?
  end

  def check_overlap?
    membership.present?
  end

  def update?
    authorized_to_edit_event?
  end

  def destroy?
    authorized_to_edit_event?
  end

  def manage_participants?
    authorized_to_edit_event?
  end

  def manage_occurrence?
    authorized_to_edit_event?
  end

  private

  # An event can be edited by its creator, an Owner/Admin of its family, or a
  # registered guardian of any one of its managed (no-login) participants —
  # mirrors PersonPolicy#authorized_to_edit_dependent?.
  def authorized_to_edit_event?
    return false unless membership
    return false unless record.family_id == membership.family_id

    creator? || owner_or_admin? || guardian_of_any?(record.people.select(&:managed?))
  end

  def creator?
    record.created_by_user_id == context.user.id
  end
end
