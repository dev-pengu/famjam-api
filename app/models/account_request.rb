class AccountRequest < ApplicationRecord
  belongs_to :user

  enum :kind, { export: 0, deletion: 1 }
  enum :status, { pending: 0, processing: 1, completed: 2, failed: 3 }

  validates :requested_at, presence: true

  before_validation -> { self.requested_at ||= Time.current }, on: :create

  # TODO: Actual export/redaction logic is not yet implemented
end
