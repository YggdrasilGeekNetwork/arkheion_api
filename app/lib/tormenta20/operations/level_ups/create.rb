# frozen_string_literal: true

module Tormenta20
  module Operations
    module LevelUps
      class Create < BaseOperation
        def call(character_sheet:, params:)
          validated = step validate(LevelUpContract, params)
          level_up = step create_level_up(character_sheet, validated)

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

          persist(level_up)
        end
      end
    end
  end
end
