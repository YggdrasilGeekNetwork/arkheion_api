# frozen_string_literal: true

module Mutations
  module Auth
    class Logout < GraphQL::Schema::Mutation
      field :success, Boolean, null: false
      field :errors, [String], null: true

      def resolve
        user = context[:current_user]
        raise GraphQL::ExecutionError, "Not authenticated" unless user

        result = ::Auth::Operations::Logout.new.call(user: user)

        case result
        in Dry::Monads::Success
          { success: true, errors: nil }
        in Dry::Monads::Failure[_, message]
          { success: false, errors: [message] }
        end
      end
    end
  end
end
