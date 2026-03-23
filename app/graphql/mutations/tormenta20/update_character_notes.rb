# frozen_string_literal: true

module Mutations
  module Tormenta20
    class UpdateCharacterNotes < BaseMutation
      argument :id,    ID,                    required: true
      argument :notes, GraphQL::Types::JSON,  required: true

      field :character, Types::Tormenta20::CharacterType, null: true
      field :errors,    [String], null: true

      def resolve(id:, notes:)
        require_authentication!

        result = ::Tormenta20::Actions::Characters::UpdateField.call(
          id: id,
          user: current_user,
          state_updates: { notes: notes }
        )

        handle_result(result)
      end
    end
  end
end
