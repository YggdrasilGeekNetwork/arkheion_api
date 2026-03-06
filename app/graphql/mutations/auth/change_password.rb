# frozen_string_literal: true

module Mutations
  module Auth
    class ChangePassword < GraphQL::Schema::Mutation
      argument :current_password, String, required: true
      argument :new_password, String, required: true
      argument :new_password_confirmation, String, required: true

      field :user, Types::Auth::UserType, null: true
      field :access_token, String, null: true
      field :refresh_token, String, null: true
      field :errors, [String], null: true

      def resolve(current_password:, new_password:, new_password_confirmation:)
        user = context[:current_user]
        raise GraphQL::ExecutionError, 'Not authenticated' unless user

        result = ::Auth::Operations::ChangePassword.new.call(
          user: user,
          current_password: current_password,
          new_password: new_password,
          new_password_confirmation: new_password_confirmation
        )

        case result
        in Dry::Monads::Success(user:, tokens:)
          {
            user: user,
            access_token: tokens[:access_token],
            refresh_token: tokens[:refresh_token],
            errors: nil
          }
        in Dry::Monads::Failure[:invalid_credentials, message]
          {
            user: nil,
            access_token: nil,
            refresh_token: nil,
            errors: [message]
          }
        in Dry::Monads::Failure[:validation_error, errors]
          {
            user: nil,
            access_token: nil,
            refresh_token: nil,
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
