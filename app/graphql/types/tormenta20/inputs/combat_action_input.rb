# frozen_string_literal: true

module Types
  module Tormenta20
    module Inputs
      class CombatActionInput < Types::BaseInputObject
        argument :action_type, String, required: true
        argument :amount, Integer, required: true
        argument :damage_type, String, required: false
        argument :source, String, required: false
      end
    end
  end
end
