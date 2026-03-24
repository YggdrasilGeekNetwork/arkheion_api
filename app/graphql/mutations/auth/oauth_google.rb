# frozen_string_literal: true

module Mutations
  module Auth
    class OauthGoogle < GraphQL::Schema::Mutation
      argument :id_token, String, required: true

      field :user, Types::Auth::UserType, null: true
      field :access_token, String, null: true
      field :refresh_token, String, null: true
      field :errors, [String], null: true

      def resolve(id_token:)
        result = ::Auth::Operations::OauthGoogle.new.call(id_token: id_token)

        case result
        in Dry::Monads::Success(user:, tokens:)
          {
            user: user,
            access_token: tokens[:access_token],
            refresh_token: tokens[:refresh_token],
            errors: nil
          }
        in Dry::Monads::Failure[_, message]
          {
            user: nil, access_token: nil, refresh_token: nil,
            errors: [message]
          }
        end
      end
    end
  end
end
