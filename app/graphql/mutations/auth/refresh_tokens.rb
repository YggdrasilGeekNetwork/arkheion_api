# frozen_string_literal: true

module Mutations
  module Auth
    class RefreshTokens < GraphQL::Schema::Mutation
      argument :refresh_token, String, required: true

      field :access_token, String, null: true
      field :refresh_token, String, null: true
      field :errors, [String], null: true

      def resolve(refresh_token:)
        result = ::Auth::Operations::RefreshToken.new.call(
          refresh_token: refresh_token
        )

        case result
        in Dry::Monads::Success(tokens:)
          {
            access_token: tokens[:access_token],
            refresh_token: tokens[:refresh_token],
            errors: nil
          }
        in Dry::Monads::Failure[:invalid_token, message]
          {
            access_token: nil,
            refresh_token: nil,
            errors: [message]
          }
        end
      end
    end
  end
end
