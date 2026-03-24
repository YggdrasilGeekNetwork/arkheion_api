# frozen_string_literal: true

module Queries
  module Tormenta20
    class CharacterSheetQuery < GraphQL::Schema::Resolver
      type Types::Tormenta20::CharacterSheetType, null: true

      argument :id, ID, required: true

      def resolve(id:)
        current_user = context[:current_user]
        raise GraphQL::ExecutionError, "Not authenticated" unless current_user

        ::Tormenta20::CharacterSheet.find_by(id: id, user_id: current_user.id)
      end
    end
  end
end
