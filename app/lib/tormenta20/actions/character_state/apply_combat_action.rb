# frozen_string_literal: true

module Tormenta20
  module Actions
    module CharacterState
      class ApplyCombatAction < BaseAction
        def call(character_sheet:, input:)
          case input[:action_type].to_sym
          when :damage
            Operations::CharacterState::ApplyDamage.new.call(
              character_sheet: character_sheet,
              amount: input[:amount].to_i,
              damage_type: input[:damage_type],
              source: input[:source]
            )
          when :heal
            Operations::CharacterState::ApplyHealing.new.call(
              character_sheet: character_sheet,
              amount: input[:amount].to_i,
              source: input[:source]
            )
          else
            Failure[:invalid_action, "Unknown action type: #{input[:action_type]}"]
          end
        end
      end
    end
  end
end
