class RewardPolicy < ApplicationPolicy
  def index?
    membership.present?
  end

  def show?
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
end
