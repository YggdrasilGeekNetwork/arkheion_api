# frozen_string_literal: true

module Queries
  module Feedback
    class FeedbackItemsQuery < GraphQL::Schema::Resolver
      type [Types::FeedbackItemType], null: false

      def resolve
        FeedbackItem.visible.order(upvotes_count: :desc, created_at: :desc)
      end
    end
  end
end
