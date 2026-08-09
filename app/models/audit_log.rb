class AuditLog < ApplicationRecord
  belongs_to :family, optional: true
  belongs_to :actor_user, class_name: "User", optional: true
  belongs_to :target, polymorphic: true, optional: true

  validates :action, presence: true

  def self.record!(action:, actor_user: nil, family: nil, target: nil, metadata: {})
    create!(
      action: action,
      actor_user: actor_user,
      family: family,
      target: target,
      metadata: metadata,
    )
  end
end
