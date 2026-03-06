# frozen_string_literal: true

module Mutations
  module Tormenta20
    class UpdateCharacterSpells < BaseMutation
      argument :id,     ID, required: true
      argument :spells, [Types::Tormenta20::Inputs::SpellInput], required: true

      field :character, Types::Tormenta20::CharacterType, null: true
      field :errors,    [String], null: true

      def resolve(id:, spells:)
        require_authentication!

        result = ::Tormenta20::Operations::Characters::UpdateField.new.call(
          id: id,
          user: current_user,
          sheet_updates: { spells_data: spells.map(&:to_h) }
        )

        handle_result(result)
      end
    end
  end
end
