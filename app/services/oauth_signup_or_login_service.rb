# Handles Oauth login sequencing. If a User already exists with the email provided, returnes a `:linking_required`
# failure so the frontend can prompt for existing password before linking. If a User does not exist, creates a
# brand new Person+User+Identity relationship.
class OauthSignupOrLoginService < ApplicationService
  def initialize(provider:, provider_uid:, email:, first_name:, last_name:, provider_email_verified: false)
    @provider = provider
    @provider_uid = provider_uid
    @email = email
    @first_name = first_name
    @last_name = last_name
    @provider_email_verified = provider_email_verified
  end

  def call
    identity = Identity.find_by(provider: @provider, provider_uid: @provider_uid)
    return ServiceResult.success(identity.user) if identity

    existing_user = User.find_by(email: @email)
    if existing_user
      return ServiceResult.failure([{ code: :linking_required, user_id: existing_user.id }])
    end

    user = nil
    ActiveRecord::Base.transaction do
      person = Person.create!(first_name: @first_name, last_name: @last_name)
      user = User.create!(
        person: person,
        email: @email,
        email_verified_at: @provider_email_verified ? Time.current : nil,
      )
      user.identities.create!(provider: @provider, provider_uid: @provider_uid)
    end

    AuditLogger.log(action: 'user.signed_up', actor_user: user, metadata: { method: @provider })
    ServiceResult.success(user)
  rescue ActiveRecord::RecordInvalid => e
    ServiceResult.failure(e.record.errors.full_messages)
  end
end
