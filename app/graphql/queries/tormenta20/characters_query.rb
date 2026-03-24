# frozen_string_literal: true

module Queries
  module Tormenta20
    class CharactersQuery < GraphQL::Schema::Resolver
      type [Types::Tormenta20::CharacterSummaryType], null: false

      def resolve
        current_user = context[:current_user]
        raise GraphQL::ExecutionError, "Not authenticated" unless current_user

        ::Tormenta20::CharacterSheet.where(user_id: current_user.id).order(updated_at: :desc)
      end
    end
  end
end
