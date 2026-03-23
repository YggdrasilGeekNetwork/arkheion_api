# frozen_string_literal: true

class FeedbackUpvote < ApplicationRecord
  belongs_to :feedback_item, counter_cache: :upvotes_count
  belongs_to :user

  validates :user_id, uniqueness: { scope: :feedback_item_id }
end
