# frozen_string_literal: true

module Mutations
  module Tormenta20
    class UpdateCharacterAbilities < BaseMutation
      argument :id,        ID, required: true
      argument :abilities, [Types::Tormenta20::Inputs::AbilityInput], required: true

      field :character, Types::Tormenta20::CharacterType, null: true
      field :errors,    [String], null: true

      def resolve(id:, abilities:)
        require_authentication!

        result = ::Tormenta20::Operations::Characters::UpdateField.new.call(
          id: id,
          user: current_user,
          sheet_updates: { abilities_data: abilities.map(&:to_h) }
        )

        handle_result(result)
      end
    end
  end
end
