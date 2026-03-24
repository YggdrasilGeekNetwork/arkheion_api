# frozen_string_literal: true

module Mutations
  module Auth
    class ResetPassword < GraphQL::Schema::Mutation
      argument :token, String, required: true
      argument :password, String, required: true
      argument :password_confirmation, String, required: true

      field :user, Types::Auth::UserType, null: true
      field :access_token, String, null: true
      field :refresh_token, String, null: true
      field :errors, [String], null: true

      def resolve(token:, password:, password_confirmation:)
        result = ::Auth::Operations::ResetPassword.new.call(
          token: token,
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
        in Dry::Monads::Failure[_, message]
          {
            user: nil, access_token: nil, refresh_token: nil,
            errors: [message]
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
