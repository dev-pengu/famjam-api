class MemberLeaveService < ApplicationService
  def initialize(membership:)
    @membership = membership
  end

  def call
    @membership.leave!
    AuditLogger.log(
      action: "member.left",
      actor_user: @membership.person.user,
      family: @membership.family,
      target: @membership,
    )
    ServiceResult.success(@membership)
  end
end
