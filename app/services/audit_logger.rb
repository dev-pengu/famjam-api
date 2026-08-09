class AuditLogger
  SENSITIVE_KEYS = %i[
    password password_confirmation password_digest
    token raw_token access_token refresh_token code
  ].freeze

  def self.log(action:, actor_user: nil, family: nil, target: nil, metadata: {})
    AuditLog.record!(
      action: action,
      actor_user: actor_user,
      family: family,
      target: target,
      metadata: scrub(metadata),
    )
  rescue StandardError => e
    # Audit logging must never be the reason a real action fails. Report and
    # move on rather than raising into the caller's transaction.
    Rails.logger.error("[AuditLogger] failed to record action=#{action}: #{e.message}")
    nil
  end

  def self.scrub(metadata)
    metadata.each_with_object({}) do |(key, value), result|
      result[key] = SENSITIVE_KEYS.include?(key.to_sym) ? "[REDACTED]" : value
    end
  end
  private_class_method :scrub
end
