# frozen_string_literal: true

module Mutations
  module Tormenta20
    class UpdateCharacterActionsList < BaseMutation
      argument :id,          ID, required: true
      argument :actions_list, [Types::Tormenta20::Inputs::CombatActionInput], required: true

      field :character, Types::Tormenta20::CharacterType, null: true
      field :errors,    [String], null: true

      def resolve(id:, actions_list:)
        require_authentication!

        result = ::Tormenta20::Operations::Characters::UpdateField.new.call(
          id: id,
          user: current_user,
          sheet_updates: { actions_list_data: actions_list.map(&:to_h) }
        )

        handle_result(result)
      end
    end
  end
end
