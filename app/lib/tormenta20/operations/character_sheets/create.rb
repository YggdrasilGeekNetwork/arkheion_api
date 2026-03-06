# frozen_string_literal: true

module Tormenta20
  module Operations
    module CharacterSheets
      class Create < BaseOperation
        def call(params:, first_level_params:, user:)
          validated = step validate(CharacterSheetContract, params)
          sheet = step create_sheet(validated, user)
          level_up = step create_first_level(sheet, first_level_params)
          step generate_initial_snapshot(sheet)
          step initialize_state(sheet)

          Success(character_sheet: sheet.reload, level_up: level_up)
        end

        private

        def create_sheet(params, user)
          sheet = CharacterSheet.new(
            user: user,
            name: params[:name],
            race_key: params[:race_key],
            origin_key: params[:origin_key],
            deity_key: params[:deity_key],
            sheet_attributes: params[:sheet_attributes],
            race_choices: params[:race_choices] || {},
            origin_choices: params[:origin_choices] || {},
            proficiencies: params[:proficiencies] || {},
            metadata: params[:metadata] || {}
          )

          persist(sheet)
        end

        def create_first_level(sheet, level_params)
          return Success(nil) unless level_params

          LevelUps::Create.new.call(
            character_sheet: sheet,
            params: level_params.merge(level: 1)
          )
        end

        def generate_initial_snapshot(sheet)
          Snapshots::Generate.new.call(character_sheet: sheet, force: true)
        end

        def initialize_state(sheet)
          snapshot_result = Snapshots::Generate.new.call(character_sheet: sheet)
          return snapshot_result if snapshot_result.failure?

          snapshot = snapshot_result.value![:snapshot]
          state = sheet.character_state

          state.update!(
            current_pv: snapshot.pv_max,
            current_pm: snapshot.pm_max
          )

          Success(state)
        end
      end
    end
  end
end
