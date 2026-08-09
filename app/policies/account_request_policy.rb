class AccountRequestPolicy < ApplicationPolicy
  def create?
    record.user_id == context.user.id
  end

  def show?
    record.user_id == context.user.id
  end
end
