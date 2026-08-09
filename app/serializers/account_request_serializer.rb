class AccountRequestSerializer < ApplicationSerializer
  private

  def serialize(request)
    {
      id: request.id,
      kind: request.kind,
      status: request.status,
      requested_at: request.requested_at,
      completed_at: request.completed_at,
      download_url: request.status == "completed" ? request.download_url : nil
    }
  end
end
