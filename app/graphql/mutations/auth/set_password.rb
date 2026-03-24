# frozen_string_literal: true

module Mutations
  module Auth
    class SetPassword < GraphQL::Schema::Mutation
      argument :password, String, required: true
      argument :password_confirmation, String, required: true

      field :user, Types::Auth::UserType, null: true
      field :access_token, String, null: true
      field :refresh_token, String, null: true
      field :errors, [String], null: true

      def resolve(password:, password_confirmation:)
        user = context[:current_user]
        raise GraphQL::ExecutionError, "Not authenticated" unless user

        result = ::Auth::Operations::SetPassword.new.call(
          user: user,
          password: password,
          password_confirmation: password_confirmation
        )

        case result
        in Dry::Monads::Success(user:, tokens:)
          {
            user: user,
            access_token: tokens[:access_token],
            refresh_token: tokens[:refresh_token],
            errors: nil
          }
        in Dry::Monads::Failure[:validation_error, errors]
          {
            user: nil, access_token: nil, refresh_token: nil,
            errors: format_errors(errors)
          }
        end
      end

      private

      def format_errors(errors)
        errors.map { |field, messages| "#{field}: #{Array(messages).join(', ')}" }
      end
    end
  end
end
