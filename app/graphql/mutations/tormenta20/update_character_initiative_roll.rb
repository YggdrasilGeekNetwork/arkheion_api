# frozen_string_literal: true

module Mutations
  module Tormenta20
    class UpdateCharacterInitiativeRoll < BaseMutation
      argument :id,              ID,      required: true
      argument :initiative_roll, Integer, required: false

      field :character, Types::Tormenta20::CharacterType, null: true
      field :errors,    [String], null: true

      def resolve(id:, initiative_roll: nil)
        require_authentication!

        result = ::Tormenta20::Actions::Characters::UpdateField.call(
          id: id,
          user: current_user,
          state_updates: { initiative_roll_value: initiative_roll }
        )

        handle_result(result)
      end
    end
  end
end
