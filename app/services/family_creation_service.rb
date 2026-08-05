class FamilyCreationService < ApplicationService
  def initialize(user:, name:)
    @user = user
    @name = name
  end

  def call
    family = nil
    membership = nil

    ActiveRecord::Base.transaction do
      family = Family.create!(name: @name)
      membership = family.memberships.create!(
        person: @user.person, role: :owner, status: :active, joined_at: Time.current,
      )
    end

    @user.update!(active_family: family)
    AuditLogger.log(action: 'family.created', actor_user: @user, family: family, target: membership)

    ServiceResult.success(family)
  rescue ActiveRecord::RecordInvalid => e
    ServiceResult.failure(e.record.errors.full_messages)
  end
end
