# frozen_string_literal: true

# == Schema Information
#
# Table name: guests
#
#  id         :uuid             not null, primary key
#  email      :string           not null
#  used_at    :datetime
#  notes      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null

class Guest < ApplicationRecord
  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }

  before_save :downcase_email

  scope :pending, -> { where(used_at: nil) }
  scope :used, -> { where.not(used_at: nil) }

def used?
    used_at.present?
  end

  def mark_as_used!
    update!(used_at: Time.current)
  end

  # When a guest is destroyed, also destroy the associated user (if any).
  before_destroy :destroy_associated_user

  private

  def downcase_email
    self.email = email.downcase
  end

  def destroy_associated_user
    User.find_by(email: email)&.destroy
  end
end
