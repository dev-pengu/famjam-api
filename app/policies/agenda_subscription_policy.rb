class AgendaSubscriptionPolicy < ApplicationPolicy
  def index?
    membership.present?
  end

  def create?
    membership.present?
  end

  def update?
    self_owned?
  end

  def destroy?
    self_owned?
  end

  private

  def self_owned?
    record.user_id == context.user.id
  end
end
