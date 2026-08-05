class UserSerializer < ApplicationSerializer
  private

  def serialize(user)
    {
      id: user.id,
      email: user.email,
      email_verified: user.verified?,
      locked: user.locked?,
      active_family_id: user.active_family_id,
      last_login_at: user.last_login_at,
      created_at: user.created_at,
      person: PersonSerializer.new(user.person).as_json,
    }
  end
end
