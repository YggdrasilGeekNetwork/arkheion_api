# frozen_string_literal: true

module Tormenta20
  module Operations
    module LevelUps
      class Add < BaseOperation
        def call(character_sheet_id:, params:, user:)
          sheet = step find_character_sheet(character_sheet_id, user: user)
          step authorize!(user: user, resource: sheet, action: :update)
          step validate_can_level_up(sheet)

          level_params = params.merge(level: sheet.current_level + 1)
          result = step Create.new.call(character_sheet: sheet, params: level_params)

          step regenerate_snapshot(sheet.reload)
          step update_resources_after_level_up(sheet)

          Success(
            character_sheet: sheet.reload,
            level_up: result[:level_up]
          )
        end

        private

        def validate_can_level_up(sheet)
          if sheet.can_level_up?
            Success(true)
          else
            Failure[:max_level, 'Character is already at maximum level']
          end
        end

        def regenerate_snapshot(sheet)
          Snapshots::Generate.new.call(character_sheet: sheet, force: true)
        end

        def update_resources_after_level_up(sheet)
          snapshot_result = Snapshots::Generate.new.call(character_sheet: sheet)
          return snapshot_result if snapshot_result.failure?

          snapshot = snapshot_result.value![:snapshot]
          state = sheet.character_state

          pv_increase = [snapshot.pv_max - state.current_pv, 0].max
          pm_increase = [snapshot.pm_max - state.current_pm, 0].max

          state.update!(
            current_pv: state.current_pv + pv_increase,
            current_pm: state.current_pm + pm_increase
          )

          Success(state)
        end
      end
    end
  end
end
