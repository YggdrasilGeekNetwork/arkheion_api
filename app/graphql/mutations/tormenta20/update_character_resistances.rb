# frozen_string_literal: true

module Mutations
  module Tormenta20
    class UpdateCharacterResistances < BaseMutation
      argument :id,          ID, required: true
      argument :resistances, [Types::Tormenta20::Inputs::ResistanceInput], required: true

      field :character, Types::Tormenta20::CharacterType, null: true
      field :errors,    [String], null: true

      def resolve(id:, resistances:)
        require_authentication!

        result = ::Tormenta20::Operations::Characters::UpdateField.new.call(
          id: id,
          user: current_user,
          sheet_updates: { resistances_data: resistances.map(&:to_h) }
        )

        handle_result(result)
      end
    end
  end
end
