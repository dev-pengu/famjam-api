class RefreshTokenPolicy < ApplicationPolicy
  def index?
    true # scope handles filtering to the current user's own tokens
  end

  def revoke?
    record.user_id == context.user.id
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(user_id: context.user.id)
    end
  end
end