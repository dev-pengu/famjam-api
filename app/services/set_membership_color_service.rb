class SetMembershipColorService < ApplicationService
  def initialize(actor:, membership:, color:)
    @actor = actor
    @membership = membership
    @color = color
  end

  def call
    previous_color = @membership.color
    @membership.update!(color: @color)

    AuditLogger.log(
      action: 'member.color_changed',
      actor_user: @actor,
      family: @membership.family,
      target: @membership,
      metadata: { from: previous_color, to: @color },
    )

    ServiceResult.success(@membership)
  rescue ActiveRecord::RecordInvalid => e
    ServiceResult.failure(e.record.errors.full_messages)
  end
end
