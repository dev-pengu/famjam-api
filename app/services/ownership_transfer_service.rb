class OwnershipTransferService < ApplicationService
  def initialize(current_owner_membership:, new_owner_membership:)
    @current_owner_membership = current_owner_membership
    @new_owner_membership = new_owner_membership
  end

  def call
    unless @new_owner_membership.family_id == @current_owner_membership.family_id
      return ServiceResult.failure([ "memberships must belong to the same family" ])
    end

    ActiveRecord::Base.transaction do
      @current_owner_membership.update!(role: :admin)
      @new_owner_membership.update!(role: :owner)
    end

    AuditLogger.log(
      action: "ownership.transferred",
      actor_user: @current_owner_membership.person.user,
      family: @current_owner_membership.family,
      target: @new_owner_membership,
      metadata: {
        previous_owner_person_id: @current_owner_membership.person_id,
        new_owner_person_id: @new_owner_membership.person_id
      },
    )

    ServiceResult.success(@new_owner_membership)
  rescue ActiveRecord::RecordInvalid => e
    ServiceResult.failure(e.record.errors.full_messages)
  end
end
