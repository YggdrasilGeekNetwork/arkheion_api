# frozen_string_literal: true

module Tormenta20
  module Interactions
    module LevelUps
      class Create < BaseInteraction
        def call(character_sheet:, params:)
          validated = yield validate(LevelUpContract, params)
          level_up = yield create_level_up(character_sheet, validated)
          yield update_character_level(character_sheet)

          Success(level_up: level_up)
        end

        private

        def create_level_up(sheet, params)
          level_up = sheet.level_ups.new(
            level: params[:level],
            class_key: params[:class_key],
            class_choices: params[:class_choices] || {},
            skill_points: params[:skill_points] || {},
            abilities_chosen: params[:abilities_chosen] || {},
            powers_chosen: params[:powers_chosen] || {},
            spells_chosen: params[:spells_chosen] || {},
            metadata: params[:metadata] || {}
          )

          if level_up.save
            Success(level_up)
          else
            Failure(errors: level_up.errors.to_h)
          end
        end

        def update_character_level(sheet)
          sheet.reload
          Success(sheet)
        end
      end
    end
  end
end
