# frozen_string_literal: true

module Mutations
  module Tormenta20
    class DeleteCharacter < BaseMutation
      argument :id, ID, required: true

      field :success, Boolean, null: false
      field :errors,  [String], null: true

      def resolve(id:)
        require_authentication!

        result = ::Tormenta20::Operations::Characters::Delete.new.call(
          id: id,
          user: current_user
        )

        case result
        in Dry::Monads::Success(true)
          { success: true }
        in Dry::Monads::Failure[:not_found, message]
          raise GraphQL::ExecutionError, message
        in Dry::Monads::Failure[_, message]
          raise GraphQL::ExecutionError, message.to_s
        end
      end
    end
  end
end
