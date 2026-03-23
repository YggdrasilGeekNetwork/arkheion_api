# frozen_string_literal: true

module Mutations
  module Feedback
    class SubmitFeedback < GraphQL::Schema::Mutation
      argument :title,       String, required: true
      argument :description, String, required: false

      field :feedback_item, Types::FeedbackItemType, null: true
      field :errors, [String], null: false

      def resolve(title:, description: nil)
        current_user = context[:current_user]
        raise GraphQL::ExecutionError, "Not authenticated" unless current_user

        item = FeedbackItem.new(
          title: title,
          description: description,
          user: current_user
        )

        if item.save
          { feedback_item: item, errors: [] }
        else
          { feedback_item: nil, errors: item.errors.full_messages }
        end
      end
    end
  end
end
