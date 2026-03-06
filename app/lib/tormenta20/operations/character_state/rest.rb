# frozen_string_literal: true

module Tormenta20
  module Operations
    module CharacterState
      class Rest < BaseOperation
        def call(character_sheet:, rest_type:)
          state = character_sheet.character_state
          return Failure[:not_found, 'State not found'] unless state

          snapshot = step get_snapshot(character_sheet)

          case rest_type.to_sym
          when :full, :long
            full_rest(state, snapshot)
          when :short
            short_rest(state, snapshot)
          else
            Failure[:invalid_rest_type, "Unknown rest type: #{rest_type}"]
          end
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

        def full_rest(state, snapshot)
          state.rest_full(snapshot)

          Success(
            state: state,
            rest_type: :full,
            current_pv: state.current_pv,
            current_pm: state.current_pm,
            max_pv: snapshot.pv_max,
            max_pm: snapshot.pm_max
          )
        end

        def short_rest(state, snapshot)
          pv_recovery = (snapshot.pv_max * 0.25).floor
          pm_recovery = (snapshot.pm_max * 0.25).floor

          state.heal(pv_recovery, max_pv: snapshot.pv_max)
          state.recover_pm(pm_recovery, max_pm: snapshot.pm_max)

          Success(
            state: state,
            rest_type: :short,
            pv_recovered: pv_recovery,
            pm_recovered: pm_recovery,
            current_pv: state.current_pv,
            current_pm: state.current_pm
          )
        end
      end
    end
  end
end
