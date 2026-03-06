# frozen_string_literal: true

module Tormenta20
  module Interactions
    module CharacterState
      class ApplyHealing < BaseInteraction
        def call(character_sheet:, amount:, source: nil)
          state = character_sheet.character_state
          return Failure(error: :not_found) unless state

          snapshot = yield get_snapshot(character_sheet)
          yield apply_healing_to_state(state, amount, snapshot.pv_max)

          Success(
            state: state,
            healing_received: amount,
            current_pv: state.current_pv,
            max_pv: snapshot.pv_max
          )
        end

        private

        def get_snapshot(sheet)
          result = Snapshots::Generate.call(character_sheet: sheet)

          if result.success?
            Success(result.value![:snapshot])
          else
            Failure(result.failure)
          end
        end

        def apply_healing_to_state(state, amount, max_pv)
          state.heal(amount, max_pv: max_pv)
          Success(state)
        rescue StandardError => e
          Failure(error: :internal, message: e.message)
        end
      end
    end
  end
end
