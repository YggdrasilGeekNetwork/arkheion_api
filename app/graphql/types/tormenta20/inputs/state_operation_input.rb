# frozen_string_literal: true

module Types
  module Tormenta20
    module Inputs
      class EquipItemInput < Types::BaseInputObject
        argument :slot, String, required: true
        argument :item_id, String, required: false
        argument :item_key, String, required: true
        argument :enhancements, [String], required: false
      end

      class ConditionInput < Types::BaseInputObject
        argument :condition_key, String, required: true
        argument :duration, Integer, required: false
        argument :duration_unit, String, required: false
        argument :source, String, required: false
        argument :stacks, Integer, required: false
      end

      class StateOperationInput < Types::BaseInputObject
        argument :operation, String, required: true
        argument :slot, String, required: false
        argument :item_data, EquipItemInput, required: false
        argument :condition_key, String, required: false
        argument :condition, ConditionInput, required: false
        argument :rest_type, String, required: false
      end
    end
  end
end
