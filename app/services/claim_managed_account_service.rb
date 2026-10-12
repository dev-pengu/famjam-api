class ClaimManagedAccountService < ApplicationService
  def initialize(actor:, membership:, email:, password:)
    @actor = actor
    @membership = membership
    @person = membership.person
    @email = email
    @password = password
  end

  def call
    return ServiceResult.failure([ "this profile already has its own login" ]) unless @person.managed?

    user = nil
    removed_guardian_count = 0

    ActiveRecord::Base.transaction do
      user = User.create!(person: @person, email: @email, password: @password)

      # Once this person can log in and manage their own account, an adult
      # being registered as their "guardian" (with edit rights over their
      # profile) no longer makes sense
      removed_guardian_count = @person.guardianships.count
      @person.guardianships.destroy_all
    end

    UserMailer.verification_email(user).deliver_later

    AuditLogger.log(
      action: "person.account_claimed",
      actor_user: @actor,
      family: @membership.family,
      target: user,
      metadata: { person_id: @person.id, membership_id: @membership.id, guardianships_removed: removed_guardian_count },
    )

    ServiceResult.success(user)
  rescue ActiveRecord::RecordInvalid => e
    ServiceResult.failure(e.record.errors.full_messages)
  end
end
