# frozen_string_literal: true

module Mutations
  module Tormenta20
    class ManageState < BaseMutation
      argument :character_sheet_id, ID, required: true
      argument :input, Types::Tormenta20::Inputs::StateOperationInput, required: true

      field :state, Types::Tormenta20::CharacterStateType, null: true
      field :errors, [String], null: true

      def resolve(character_sheet_id:, input:)
        require_authentication!

        sheet = find_character_sheet!(character_sheet_id)

        result = case input[:operation].to_sym
                 when :equip
                   ::Tormenta20::Operations::CharacterState::ManageEquipment.new.call(
                     character_sheet: sheet,
                     action: :equip,
                     slot: input[:slot],
                     item_data: input[:item_data]&.to_h
                   )
                 when :unequip
                   ::Tormenta20::Operations::CharacterState::ManageEquipment.new.call(
                     character_sheet: sheet,
                     action: :unequip,
                     slot: input[:slot]
                   )
                 when :add_condition
                   condition_params = input[:condition]&.to_h || {}
                   ::Tormenta20::Operations::CharacterState::ManageConditions.new.call(
                     character_sheet: sheet,
                     action: :add,
                     condition_key: input[:condition_key] || condition_params[:condition_key],
                     **condition_params.except(:condition_key).symbolize_keys
                   )
                 when :remove_condition
                   ::Tormenta20::Operations::CharacterState::ManageConditions.new.call(
                     character_sheet: sheet,
                     action: :remove,
                     condition_key: input[:condition_key]
                   )
                 when :rest
                   ::Tormenta20::Operations::CharacterState::Rest.new.call(
                     character_sheet: sheet,
                     rest_type: input[:rest_type]
                   )
                 else
                   raise GraphQL::ExecutionError, "Unknown operation: #{input[:operation]}"
                 end

        handle_result(result)
      end
    end
  end
end
