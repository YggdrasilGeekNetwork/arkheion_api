# frozen_string_literal: true

module Mutations
  module Auth
    class Login < GraphQL::Schema::Mutation
      argument :email, String, required: true
      argument :password, String, required: true

      field :user, Types::Auth::UserType, null: true
      field :access_token, String, null: true
      field :refresh_token, String, null: true
      field :errors, [String], null: true

      def resolve(email:, password:)
        result = ::Auth::Operations::Login.new.call(
          email: email,
          password: password
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
        in Dry::Monads::Failure[:account_disabled, message]
          raise GraphQL::ExecutionError, message
        end
      end
    end
  end
end
