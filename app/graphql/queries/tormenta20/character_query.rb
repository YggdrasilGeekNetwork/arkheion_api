# frozen_string_literal: true

module Queries
  module Tormenta20
    class CharacterQuery < GraphQL::Schema::Resolver
      type Types::Tormenta20::CharacterType, null: false

      argument :id, ID, required: true

      def resolve(id:)
        current_user = context[:current_user]
        raise GraphQL::ExecutionError, 'Not authenticated' unless current_user

        sheet = ::Tormenta20::CharacterSheet.find_by(id: id, user_id: current_user.id)
        raise GraphQL::ExecutionError, "Character not found" unless sheet

        ::Tormenta20::Presenters::CharacterPresenter.new(sheet)
      end
    end
  end
end
