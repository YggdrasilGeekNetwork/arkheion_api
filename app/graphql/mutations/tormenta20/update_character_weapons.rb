# frozen_string_literal: true

module Mutations
  module Tormenta20
    class UpdateCharacterWeapons < BaseMutation
      argument :id,      ID, required: true
      argument :weapons, [Types::Tormenta20::Inputs::WeaponAttackInput], required: true

      field :character, Types::Tormenta20::CharacterType, null: true
      field :errors,    [String], null: true

      def resolve(id:, weapons:)
        require_authentication!

        result = ::Tormenta20::Actions::Characters::UpdateField.call(
          id: id,
          user: current_user,
          sheet_updates: { weapons_data: weapons.map(&:to_h) }
        )

        handle_result(result)
      end
    end
  end
end
