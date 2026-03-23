# frozen_string_literal: true

module Types
  class FeedbackItemType < Types::BaseObject
    field :id,            ID,      null: false
    field :title,         String,  null: false
    field :description,   String,  null: true
    field :status,        String,  null: false
    field :progress,      Integer, null: false
    field :upvotes_count, Integer, null: false
    field :upvoted,       Boolean, null: false
    field :created_at,    GraphQL::Types::ISO8601DateTime, null: false

    def upvoted
      current_user = context[:current_user]
      return false unless current_user

      object.upvoted_by?(current_user)
    end
  end
end
