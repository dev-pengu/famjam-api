class RefreshToken < ApplicationRecord
  belongs_to :user

  scope :active, -> { where(revoked_at: nil).where('expires_at > ?', Time.current) }

  # Stores only the hash; the raw token is returned once at issuance time and
  # never persisted. Rotate on every refresh — if a rotated-out (already
  # revoked) token is ever presented again, treat it as reuse/compromise and
  # revoke every session for the user (see AuthService#refresh!).
  def self.hash_token(raw_token)
    Digest::SHA256.hexdigest(raw_token)
  end

  def revoked?
    revoked_at.present?
  end

  def expired?
    expires_at <= Time.current
  end

  def revoke!
    update!(revoked_at: Time.current)
  end
end