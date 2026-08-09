class CreateManagedChildService < ApplicationService
  def initialize(actor:, family:, first_name:, last_name:, nickname: nil)
    @actor = actor
    @family = family
    @first_name = first_name
    @last_name = last_name
    @nickname = nickname
  end

  def call
    person = nil
    membership = nil

    ActiveRecord::Base.transaction do
      person = Person.create!(first_name: @first_name, last_name: @last_name, nickname: @nickname)
      membership = @family.memberships.create!(person: person, role: :child, status: :active, joined_at: Time.current)
      @family.guardianships.create!(guardian_user: @actor, dependent_person: person, created_by_user: @actor)
    end

    AuditLogger.log(
      action: "member.managed_child_created",
      actor_user: @actor,
      family: @family,
      target: membership,
    )

    ServiceResult.success(membership)
  rescue ActiveRecord::RecordInvalid => e
    ServiceResult.failure(e.record.errors.full_messages)
  end
end
