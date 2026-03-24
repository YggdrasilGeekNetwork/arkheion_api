# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :recoverable, :confirmable

  has_many :oauth_identities, dependent: :destroy
  has_many :character_sheets,
           class_name: "Tormenta20::CharacterSheet",
           dependent: :destroy
  has_many :feedback_items, dependent: :destroy
  has_many :feedback_upvotes, dependent: :destroy

  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :username, presence: true,
                       uniqueness: { case_sensitive: false },
                       length: { minimum: 3, maximum: 30 },
                       format: { with: /\A[a-zA-Z0-9_]+\z/, message: "only allows letters, numbers, and underscores" }

  validates :password, length: { minimum: 8 }, if: -> { password.present? }

  before_create :generate_jti
  before_save :downcase_email

  scope :active, -> { where(active: true) }
  scope :confirmed, -> { where.not(confirmed_at: nil) }

  # --- Password helpers ---

  def password_required?
    return false if encrypted_password.blank? && oauth_identities.any?
    super
  end

  def oauth_only?
    encrypted_password.blank? && oauth_identities.any?
  end

  def has_password?
    encrypted_password.present?
  end

  # --- Confirmation ---

  def confirmed?
    confirmed_at.present?
  end

  def confirm!
    update!(
      confirmed_at: Time.current,
      confirmation_token: nil
    )
  end

  # Override Devise's send_confirmation_instructions to use our mailer.
  # generate_confirmation_token! sets the raw token and persists it; Devise's
  # version returns the raw token before hashing (when :confirmable is used
  # without the hashed_token strategy, which is the default for devise).
  def send_confirmation_instructions
    raw = generate_confirmation_token!
    UserMailer.confirmation_email(self, raw).deliver_later
    raw
  end

  # Override Devise's send_reset_password_instructions to use our mailer.
  def send_reset_password_instructions
    raw, enc = Devise.token_generator.generate(self.class, :reset_password_token)
    self.reset_password_token   = enc
    self.reset_password_sent_at = Time.now.utc
    save(validate: false)
    UserMailer.reset_password_email(self, raw).deliver_later
    raw
  end

  def reset_password_token_valid?
    reset_password_token.present? &&
      reset_password_sent_at.present? &&
      reset_password_sent_at > 6.hours.ago
  end

  # --- JTI (JWT ID) ---

  def regenerate_jti!
    update!(jti: SecureRandom.uuid)
  end

  private

  def generate_jti
    self.jti = SecureRandom.uuid
  end

  def downcase_email
    self.email = email.downcase
  end
end
