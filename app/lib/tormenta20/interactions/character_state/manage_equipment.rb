# frozen_string_literal: true

module Tormenta20
  module Interactions
    module CharacterState
      class ManageEquipment < BaseInteraction
        def call(character_sheet:, action:, slot:, item_data: nil)
          state = character_sheet.character_state
          return Failure(error: :not_found) unless state

          case action.to_sym
          when :equip
            equip_item(state, slot, item_data)
          when :unequip
            unequip_item(state, slot)
          else
            Failure(error: :invalid_action, message: "Unknown action: #{action}")
          end
        end

        private

        def equip_item(state, slot, item_data)
          return Failure(error: :invalid_params, message: "Item data required") unless item_data

          # Validate the item can go in this slot
          validated = yield validate_equipment_slot(slot, item_data)

          state.equip_item(slot, validated)
          Success(state: state, equipped: { slot: slot, item: validated })
        end

        def unequip_item(state, slot)
          previous = state.equipped_items[slot.to_s]
          state.unequip_item(slot)

          Success(state: state, unequipped: { slot: slot, item: previous })
        end

        def validate_equipment_slot(slot, item_data)
          valid_slots = %w[main_hand off_hand armor shield]

          unless valid_slots.include?(slot.to_s) || slot.to_s.start_with?("accessory_")
            return Failure(error: :invalid_slot, message: "Invalid slot: #{slot}")
          end

          Success(item_data.stringify_keys)
        end
      end
    end
  end
end
