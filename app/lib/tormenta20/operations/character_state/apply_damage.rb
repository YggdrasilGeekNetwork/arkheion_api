# frozen_string_literal: true

module Tormenta20
  module Operations
    module CharacterState
      class ApplyDamage < BaseOperation
        def call(character_sheet:, amount:, damage_type: nil, source: nil)
          state = character_sheet.character_state
          return Failure[:not_found, "State not found"] unless state

          damage = step calculate_effective_damage(state, amount, damage_type)
          step apply_damage_to_state(state, damage)

          Success(
            state: state,
            damage_taken: damage,
            current_pv: state.current_pv,
            is_dying: state.current_pv <= 0
          )
        end

        private

        def calculate_effective_damage(state, amount, damage_type)
          # Could apply resistances/vulnerabilities here
          Success(amount)
        end

        def apply_damage_to_state(state, damage)
          state.take_damage(damage)
          Success(state)
        rescue StandardError => e
          Failure[:internal_error, e.message]
        end
      end
    end
  end
end
