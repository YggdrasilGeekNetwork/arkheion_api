# frozen_string_literal: true

class FeedbackItem < ApplicationRecord
  STATUSES = %w[pending approved in_progress done rejected].freeze

  belongs_to :user
  has_many :feedback_upvotes, dependent: :destroy

  validates :title, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :progress, numericality: { in: 0..100 }

  scope :visible, -> { where(status: %w[approved in_progress done]) }
  scope :approved, -> { where(status: "approved") }

  def upvoted_by?(user)
    feedback_upvotes.exists?(user: user)
  end
end
