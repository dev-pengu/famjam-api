# Called after OauthSignupOrLoginService returns :linking_required and frontend has processed request for info
class AccountLinkingService < ApplicationService
  def initialize(user:, password:, provider:, provider_uid:)
    @user = user
    @password = password
    @provider = provider
    @provider_uid = provider_uid
  end

  def call
    unless @user.authenticate(@password)
      AuditLogger.log(action: 'account.link_failed', actor_user: @user, metadata: { provider: @provider })
      return ServiceResult.failure(['incorrect password'])
    end

    identity = @user.identities.create!(provider: @provider, provider_uid: @provider_uid)
    AuditLogger.log(action: 'account.linked', actor_user: @user, metadata: { provider: @provider })

    ServiceResult.success(identity)
  rescue ActiveRecord::RecordInvalid => e
    ServiceResult.failure(e.record.errors.full_messages)
  end
end