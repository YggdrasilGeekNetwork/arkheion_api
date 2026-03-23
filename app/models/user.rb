# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  has_many :character_sheets,
           class_name: 'Tormenta20::CharacterSheet',
           dependent: :destroy
  has_many :feedback_items, dependent: :destroy
  has_many :feedback_upvotes, dependent: :destroy

  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :username, presence: true,
                       uniqueness: { case_sensitive: false },
                       length: { minimum: 3, maximum: 30 },
                       format: { with: /\A[a-zA-Z0-9_]+\z/, message: 'only allows letters, numbers, and underscores' }

  validates :password, length: { minimum: 8 }, if: -> { password.present? }

  before_create :generate_jti
  before_save :downcase_email

  scope :active, -> { where(active: true) }
  scope :confirmed, -> { where.not(confirmed_at: nil) }

  def confirmed?
    confirmed_at.present?
  end

  def regenerate_jti!
    update!(jti: SecureRandom.uuid)
  end

  def generate_confirmation_token!
    update!(
      confirmation_token: SecureRandom.urlsafe_base64(32),
      confirmation_sent_at: Time.current
    )
    confirmation_token
  end

  def confirm!
    update!(
      confirmed_at: Time.current,
      confirmation_token: nil
    )
  end

  def generate_reset_password_token!
    update!(
      reset_password_token: SecureRandom.urlsafe_base64(32),
      reset_password_sent_at: Time.current
    )
    reset_password_token
  end

  def clear_reset_password_token!
    update!(
      reset_password_token: nil,
      reset_password_sent_at: nil
    )
  end

  def reset_password_token_valid?
    reset_password_token.present? &&
      reset_password_sent_at.present? &&
      reset_password_sent_at > 2.hours.ago
  end

  private

  def generate_jti
    self.jti = SecureRandom.uuid
  end

  def downcase_email
    self.email = email.downcase
  end
end
