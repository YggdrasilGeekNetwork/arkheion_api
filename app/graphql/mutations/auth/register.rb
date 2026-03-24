# frozen_string_literal: true

module Mutations
  module Auth
    class Register < GraphQL::Schema::Mutation
      argument :email, String, required: true
      argument :username, String, required: true
      argument :password, String, required: true
      argument :password_confirmation, String, required: true

      field :user, Types::Auth::UserType, null: true
      field :access_token, String, null: true
      field :refresh_token, String, null: true
      field :errors, [String], null: true

      def resolve(email:, username:, password:, password_confirmation:)
        result = ::Auth::Operations::Register.new.call(
          email: email,
          username: username,
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
          { user: nil, access_token: nil, refresh_token: nil, errors: format_errors(errors) }
        in Dry::Monads::Failure[:not_invited | :already_registered, message]
          { user: nil, access_token: nil, refresh_token: nil, errors: [message] }
        in Dry::Monads::Failure[_, message]
          raise GraphQL::ExecutionError, message
        end
      end

      private

      def format_errors(errors)
        errors.map { |field, messages| "#{field}: #{Array(messages).join(', ')}" }
      end
    end
  end
end
