# frozen_string_literal: true

module Tormenta20
  module Actions
    module CharacterState
      class Manage < BaseAction
        def call(character_sheet:, input:)
          case input[:operation].to_sym
          when :equip
            Operations::CharacterState::ManageEquipment.new.call(
              character_sheet: character_sheet,
              action: :equip,
              slot: input[:slot],
              item_data: input[:item_data]&.to_h
            )
          when :unequip
            Operations::CharacterState::ManageEquipment.new.call(
              character_sheet: character_sheet,
              action: :unequip,
              slot: input[:slot]
            )
          when :add_condition
            condition_params = input[:condition]&.to_h || {}
            Operations::CharacterState::ManageConditions.new.call(
              character_sheet: character_sheet,
              action: :add,
              condition_key: input[:condition_key] || condition_params[:condition_key],
              **condition_params.except(:condition_key).symbolize_keys
            )
          when :remove_condition
            Operations::CharacterState::ManageConditions.new.call(
              character_sheet: character_sheet,
              action: :remove,
              condition_key: input[:condition_key]
            )
          when :rest
            Operations::CharacterState::Rest.new.call(
              character_sheet: character_sheet,
              rest_type: input[:rest_type]
            )
          else
            Failure[:invalid_operation, "Unknown operation: #{input[:operation]}"]
          end
        end
      end
    end
  end
end
