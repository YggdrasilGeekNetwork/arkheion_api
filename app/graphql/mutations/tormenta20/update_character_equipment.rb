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
            equipped_items: {
              "main_hand"   => slot_key(equipped_items[:right_hand]),
              "off_hand"    => slot_key(equipped_items[:left_hand]),
              "quick_draw1" => slot_key(equipped_items[:quick_draw1]),
              "quick_draw2" => slot_key(equipped_items[:quick_draw2]),
              "slot1"       => slot_key(equipped_items[:slot1]),
              "slot2"       => slot_key(equipped_items[:slot2]),
              "slot3"       => slot_key(equipped_items[:slot3]),
              "slot4"       => slot_key(equipped_items[:slot4])
            }.compact,
            inventory: backpack.map { |item| { item_id: item[:id], item_key: item[:id], quantity: item[:quantity] || 1 } }
          }
        )

        handle_result(result)
      end

      private

      def slot_key(item)
        return nil unless item&.dig(:id).present?
        { item_key: item[:id] }
      end
    end
  end
end
