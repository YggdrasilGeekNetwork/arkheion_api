# frozen_string_literal: true

module Tormenta20
  module Interactions
    module LevelUps
      class Update < BaseInteraction
        def call(character_sheet:, level:, params:, user:)
          sheet = yield verify_ownership(character_sheet, user)
          level_up = yield find_level_up(sheet, level)
          validated = yield validate_update_params(params)
          updated = yield update_level_up(level_up, validated)

          Success(level_up: updated)
        end

        private

        def verify_ownership(sheet, user)
          if sheet.user_id == user.id
            Success(sheet)
          else
            Failure(error: :forbidden, message: "Not authorized")
          end
        end

        def find_level_up(sheet, level)
          level_up = sheet.level_ups.find_by(level: level)

          if level_up
            Success(level_up)
          else
            Failure(error: :not_found, message: "Level #{level} not found")
          end
        end

        def validate_update_params(params)
          Success(params.slice(
            :class_choices, :skill_points, :abilities_chosen,
            :powers_chosen, :spells_chosen, :metadata
          ).compact)
        end

        def update_level_up(level_up, params)
          if level_up.update(params)
            Success(level_up)
          else
            Failure(errors: level_up.errors.to_h)
          end
        end
      end
    end
  end
end
