class CreateDataExportRequestService < ApplicationService
  def initialize(user:)
    @user = user
  end

  def call
    request = @user.account_requests.create!(kind: :export, status: :pending)
    AuditLogger.log(action: 'account.export_requested', actor_user: @user, target: request)
    # TODO stubbing out a likely job call
    # AccountRequests::ExportJob.perform_later(request)
    ServiceResult.success(request)
  rescue ActiveRecord::RecordInvalid => e
    ServiceResult.failure(e.record.errors.full_messages)
  end
end

class CreateAccountDeletionRequestService < ApplicationService
  def initialize(user:)
    @user = user
  end

  def call
    request = @user.account_requests.create!(kind: :deletion, status: :pending)
    AuditLogger.log(action: 'account.deletion_requested', actor_user: @user, target: request)
    # TODO stubbing out a likely job call
    # AccountRequests::DeletionJob.perform_later(request)
    ServiceResult.success(request)
  rescue ActiveRecord::RecordInvalid => e
    ServiceResult.failure(e.record.errors.full_messages)
  end
end