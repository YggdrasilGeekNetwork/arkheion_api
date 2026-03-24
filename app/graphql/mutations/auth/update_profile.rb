# frozen_string_literal: true

module Mutations
  module Auth
    class UpdateProfile < GraphQL::Schema::Mutation
      argument :username, String, required: false
      argument :display_name, String, required: false

      field :user, Types::Auth::UserType, null: true
      field :errors, [String], null: true

      def resolve(username: nil, display_name: nil)
        user = context[:current_user]
        raise GraphQL::ExecutionError, "Not authenticated" unless user

        result = ::Auth::Operations::UpdateProfile.new.call(
          user: user,
          username: username,
          display_name: display_name
        )

        case result
        in Dry::Monads::Success(user:)
          { user: user, errors: nil }
        in Dry::Monads::Failure[:validation_error, errors]
          { user: nil, errors: format_errors(errors) }
        end
      end

      private

      def format_errors(errors)
        errors.map { |field, messages| "#{field}: #{Array(messages).join(', ')}" }
      end
    end
  end
end
