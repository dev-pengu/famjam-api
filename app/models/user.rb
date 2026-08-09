class User < ApplicationRecord
  has_secure_password validations: false

  belongs_to :person
  belongs_to :active_family, class_name: "Family", optional: true

  has_many :identities, dependent: :destroy
  has_many :refresh_tokens, dependent: :destroy
  has_many :account_requests, dependent: :destroy
  has_many :memberships, through: :person
  has_many :families, through: :memberships
  has_many :guardianships, foreign_key: :guardian_user_id, inverse_of: :guardian_user, dependent: :destroy
  has_many :dependents, through: :guardianships, source: :dependent_person
  has_many :created_invitations, class_name: "Invitation", foreign_key: :created_by_user_id
  has_many :created_events, class_name: "Event", foreign_key: :created_by_user_id
  has_many :event_reminders, dependent: :destroy
  has_many :notification_preferences, dependent: :destroy
  has_many :agenda_subscriptions, dependent: :destroy
  has_one :ical_feed_token, dependent: :destroy

  DEFAULT_LOCKOUT_MAX_ATTEMPTS = 3
  DEFAULT_LOCKOUT_DURATION = 15.minutes

  generates_token_for :email_verification, expires_in: 24.hours do
    email
  end

  generates_token_for :password_reset, expires_in: 20.minutes do
    password_digest.to_s.last(10)
  end

  validates :email, presence: true, uniqueness: { case_sensitive: false },
                     format: { with: URI::MailTo::EMAIL_REGEXP }

  scope :active, -> { where(deleted_at: nil) }


  def verified?
    email_verified_at.present?
  end

  def locked?
    locked_at.present? && locked_at > DEFAULT_LOCKOUT_DURATION.ago
  end

  def register_failed_login!
    increment!(:failed_login_attempts)
    update!(locked_at: Time.current) if failed_login_attempts >= DEFAULT_LOCKOUT_MAX_ATTEMPTS
  end

  def reset_lockout!
    update!(failed_login_attempts: 0, locked_at: nil)
  end

  def is_oauth_managed?
    identities.exists?
  end

  def has_login_credential?
    password_digest.present? || identities.exists?
  end

  def display_timezone(family: nil)
    timezone.presence || family&.timezone || Family::DEFAULT_TIMEZONE
  end

  # Opt-out model: a missing preference row means notifications of that type
  # are enabled.
  def notifies_for?(notification_type)
    notification_preferences.find_by(notification_type: notification_type)&.enabled != false
  end
end
