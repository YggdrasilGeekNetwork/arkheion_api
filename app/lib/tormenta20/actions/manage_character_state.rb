# frozen_string_literal: true

module Tormenta20
  module Actions
    class ManageCharacterState < BaseAction
      def call(character_sheet_id:, operation:, params:, user:)
        sheet = yield find_sheet(character_sheet_id, user)
        yield authorize!(user: user, resource: sheet, action: :update)

        result = yield case operation.to_sym
                       when :equip
                         Interactions::CharacterState::ManageEquipment.call(
                           character_sheet: sheet,
                           action: :equip,
                           slot: params[:slot],
                           item_data: params[:item_data]
                         )
                       when :unequip
                         Interactions::CharacterState::ManageEquipment.call(
                           character_sheet: sheet,
                           action: :unequip,
                           slot: params[:slot]
                         )
                       when :add_condition
                         Interactions::CharacterState::ManageConditions.call(
                           character_sheet: sheet,
                           action: :add,
                           condition_key: params[:condition_key],
                           **params.slice(:duration, :duration_unit, :source, :stacks).symbolize_keys
                         )
                       when :remove_condition
                         Interactions::CharacterState::ManageConditions.call(
                           character_sheet: sheet,
                           action: :remove,
                           condition_key: params[:condition_key]
                         )
                       when :rest
                         Interactions::CharacterState::Rest.call(
                           character_sheet: sheet,
                           rest_type: params[:rest_type]
                         )
                       else
                         Failure(error: :invalid_operation, message: "Unknown operation: #{operation}")
                       end

        broadcast(:character_state_changed, {
          character_id: sheet.id,
          operation: operation
        })

        Success(result)
      end

      private

      def find_sheet(id, user)
        sheet = CharacterSheet.find_by(id: id, user_id: user.id)

        if sheet
          Success(sheet)
        else
          Failure(error: :not_found)
        end
      end
    end
  end
end
