class UserPolicy < ApplicationPolicy
  def resend_verification?
    record.id == context.user&.id
  end

  def change_password?
    record.id == context.user&.id
  end
end
