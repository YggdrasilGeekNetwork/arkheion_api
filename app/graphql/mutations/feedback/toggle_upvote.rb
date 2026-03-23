# frozen_string_literal: true

module Mutations
  module Feedback
    class ToggleUpvote < GraphQL::Schema::Mutation
      argument :feedback_item_id, ID, required: true

      field :feedback_item, Types::FeedbackItemType, null: true
      field :errors, [String], null: false

      def resolve(feedback_item_id:)
        current_user = context[:current_user]
        raise GraphQL::ExecutionError, "Not authenticated" unless current_user

        item = FeedbackItem.visible.find_by(id: feedback_item_id)
        raise GraphQL::ExecutionError, "Feedback item not found" unless item

        upvote = item.feedback_upvotes.find_by(user: current_user)
        if upvote
          upvote.destroy
        else
          item.feedback_upvotes.create!(user: current_user)
        end

        item.reload
        { feedback_item: item, errors: [] }
      end
    end
  end
end
