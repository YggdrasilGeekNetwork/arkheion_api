# frozen_string_literal: true

module Queries
  module Tormenta20
    class CharacterViewQuery < GraphQL::Schema::Resolver
      type Types::Tormenta20::CharacterViewType, null: true

      argument :id, ID, required: true
      argument :live, Boolean, required: false, default_value: true

      def resolve(id:, live:)
        current_user = context[:current_user]
        raise GraphQL::ExecutionError, 'Not authenticated' unless current_user

        result = ::Tormenta20::Operations::CharacterView::Get.new.call(
          character_sheet_id: id,
          user: current_user,
          live: live
        )

        case result
        in Dry::Monads::Success(payload)
          payload
        in Dry::Monads::Failure[:not_found, message]
          raise GraphQL::ExecutionError, message
        in Dry::Monads::Failure[_, message]
          raise GraphQL::ExecutionError, message.to_s
        end
      end
    end
  end
end
