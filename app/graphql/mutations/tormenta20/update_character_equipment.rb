# frozen_string_literal: true

module Mutations
  module Tormenta20
    class UpdateCharacterEquipment < BaseMutation
      argument :id,            ID, required: true
      argument :equipped_items, Types::Tormenta20::Inputs::EquippedItemsInput, required: true
      argument :backpack,      [Types::Tormenta20::Inputs::EquipmentItemInput], required: true

      field :character, Types::Tormenta20::CharacterType, null: true
      field :errors,    [String], null: true

      def resolve(id:, equipped_items:, backpack:)
        require_authentication!

        result = ::Tormenta20::Actions::Characters::UpdateField.call(
          id: id,
          user: current_user,
          state_updates: {
            equipped_items_display: equipped_items.to_h,
            backpack_data: backpack.map(&:to_h)
          }
        )

        handle_result(result)
      end
    end
  end
end
