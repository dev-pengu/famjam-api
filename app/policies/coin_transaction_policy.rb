class CoinTransactionPolicy < ApplicationPolicy
  # View a member's coin ledger: an Owner/Admin, a registered guardian of that
  # member, or the member viewing their own history.
  def index?
    owner_or_admin? || guardian_of?(record.person) || own_membership?
  end

  private

  def own_membership?
    record.person_id == context.user.person_id
  end
end
