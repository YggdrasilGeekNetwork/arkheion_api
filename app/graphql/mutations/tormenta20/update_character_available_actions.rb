# frozen_string_literal: true

module Mutations
  module Tormenta20
    class UpdateCharacterAvailableActions < BaseMutation
      argument :id,               ID, required: true
      argument :available_actions, Types::Tormenta20::Inputs::AvailableActionsInput, required: true

      field :character, Types::Tormenta20::CharacterType, null: true
      field :errors,    [String], null: true

      def resolve(id:, available_actions:)
        require_authentication!

        result = ::Tormenta20::Actions::Characters::UpdateField.call(
          id: id,
          user: current_user,
          state_updates: { available_actions_data: available_actions.to_h }
        )

        handle_result(result)
      end
    end
  end
end
