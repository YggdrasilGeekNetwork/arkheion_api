# frozen_string_literal: true

module Tormenta20
  module Interactions
    module CharacterSheets
      class Create < BaseInteraction
        def call(params:, user:)
          validated = yield validate(CharacterSheetContract, params)
          sheet = yield create_sheet(validated, user)
          level_up = yield create_first_level(sheet, params[:first_level])

          Success(character_sheet: sheet, level_up: level_up)
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

          if sheet.save
            Success(sheet)
          else
            Failure(errors: sheet.errors.to_h)
          end
        end

        def create_first_level(sheet, level_params)
          return Success(nil) unless level_params

          LevelUps::Create.call(
            character_sheet: sheet,
            params: level_params.merge(level: 1)
          )
        end
      end
    end
  end
end
