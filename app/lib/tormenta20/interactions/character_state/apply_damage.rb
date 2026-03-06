# frozen_string_literal: true

module Tormenta20
  module Interactions
    module CharacterState
      class ApplyDamage < BaseInteraction
        def call(character_sheet:, amount:, damage_type: nil, source: nil)
          state = character_sheet.character_state
          return Failure(error: :not_found) unless state

          damage = yield calculate_effective_damage(state, amount, damage_type)
          yield apply_damage_to_state(state, damage)

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
          # For now, just return the raw amount
          Success(amount)
        end

        def apply_damage_to_state(state, damage)
          state.take_damage(damage)
          Success(state)
        rescue StandardError => e
          Failure(error: :internal, message: e.message)
        end
      end
    end
  end
end
