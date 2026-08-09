class PunditUserContext
  attr_reader :user, :membership

  def initialize(user:, family:)
    @user = user
    @membership = family && user.memberships.active.find_by(family_id: family.id)
  end
end
