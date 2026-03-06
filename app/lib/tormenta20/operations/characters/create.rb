# frozen_string_literal: true

module Tormenta20
  module Operations
    module Characters
      class Create < BaseOperation
        def call(params:, user:)
          step validate_gem_references(params)

          sheet = step build_sheet(params, user)
          sheet = step persist(sheet)

          step build_first_level_up(sheet, params)

          generate_result = Operations::Snapshots::Generate.new.call(character_sheet: sheet.reload, force: true)
          return Failure[:snapshot_error, generate_result.failure] if generate_result.failure?
          snapshot = sheet.reload.latest_snapshot
          return Failure[:snapshot_error, "Snapshot not persisted"] unless snapshot

          state = step initialize_state(sheet, snapshot)
          sheet.increment!(:character_version)

          Success(character: Presenters::CharacterPresenter.new(sheet.reload, state: state.reload, snapshot: snapshot))
        end

        private

        def validate_gem_references(params)
          race_key   = params[:race_key]
          origin_key = params[:origin_key]
          class_key  = params.dig(:first_level, :class_key)

          errors = {}

          unless ::Tormenta20::Models::Raca.find_by(id: race_key)
            errors[:race_key] = ["'#{race_key}' not found in gem"]
          end

          unless ::Tormenta20::Models::Origem.find_by(id: origin_key)
            errors[:origin_key] = ["'#{origin_key}' not found in gem"]
          end

          unless ::Tormenta20::Models::Classe.find_by(id: class_key)
            errors[:class_key] = ["'#{class_key}' not found in gem"]
          end

          if params[:deity_key].present?
            unless ::Tormenta20::Models::Divindade.find_by(id: params[:deity_key])
              errors[:deity_key] = ["'#{params[:deity_key]}' not found in gem"]
            end
          end

          errors.empty? ? Success(true) : Failure[:validation_error, errors]
        end

        def build_sheet(params, user)
          sheet = CharacterSheet.new(
            user: user,
            name: params[:name],
            image_url: params[:image_url],
            race_key: params[:race_key],
            origin_key: params[:origin_key],
            deity_key: params[:deity_key],
            sheet_attributes: params[:sheet_attributes] || {},
            race_choices: params[:race_choices] || {},
            origin_choices: params[:origin_choices] || {},
            proficiencies: {}
          )
          Success(sheet)
        end

        def build_first_level_up(sheet, params)
          first_level = (params[:first_level] || {}).merge(level: 1)
          LevelUps::Create.new.call(character_sheet: sheet, params: first_level)
        end

        def initialize_state(sheet, snapshot)
          state = sheet.character_state
          state.update!(
            current_pv: snapshot.pv_max,
            current_pm: snapshot.pm_max,
            available_actions_data: { "standard" => 1, "movement" => 1, "free" => 1, "full" => 1, "reaction" => 1 }
          )
          Success(state)
        end
      end
    end
  end
end
