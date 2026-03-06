# frozen_string_literal: true

module Tormenta20
  module Operations
    module CharacterState
      class ApplyHealing < BaseOperation
        def call(character_sheet:, amount:, source: nil)
          state = character_sheet.character_state
          return Failure[:not_found, 'State not found'] unless state

          snapshot = step get_snapshot(character_sheet)
          step apply_healing_to_state(state, amount, snapshot.pv_max)

          Success(
            state: state,
            healing_received: amount,
            current_pv: state.current_pv,
            max_pv: snapshot.pv_max
          )
        end

        private

        def get_snapshot(sheet)
          result = Snapshots::Generate.new.call(character_sheet: sheet)

          if result.success?
            Success(result.value![:snapshot])
          else
            result
          end
        end

        def apply_healing_to_state(state, amount, max_pv)
          state.heal(amount, max_pv: max_pv)
          Success(state)
        rescue StandardError => e
          Failure[:internal_error, e.message]
        end
      end
    end
  end
end
