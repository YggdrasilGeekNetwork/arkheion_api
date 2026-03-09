# frozen_string_literal: true

module Mutations
  module Tormenta20
    class ManageState < BaseMutation
      argument :character_sheet_id, ID, required: true
      argument :input, Types::Tormenta20::Inputs::StateOperationInput, required: true

      field :state, Types::Tormenta20::CharacterStateType, null: true
      field :errors, [String], null: true

      def resolve(character_sheet_id:, input:)
        require_authentication!

        sheet = find_character_sheet!(character_sheet_id)
        result = ::Tormenta20::Actions::CharacterState::Manage.call(
          character_sheet: sheet,
          input: input
        )

        handle_result(result)
      end
    end
  end
end
