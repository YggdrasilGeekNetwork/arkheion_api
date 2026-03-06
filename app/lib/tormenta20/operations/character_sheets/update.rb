# frozen_string_literal: true

module Tormenta20
  module Operations
    module CharacterSheets
      class Update < BaseOperation
        def call(id:, params:, user:)
          sheet = step find_character_sheet(id, user: user)
          step authorize!(user: user, resource: sheet, action: :update)
          updated = step update_sheet(sheet, params)

          Success(character_sheet: updated)
        end

        private

        def update_sheet(sheet, params)
          allowed_params = params.slice(
            :name, :deity_key, :sheet_attributes, :race_choices,
            :origin_choices, :proficiencies, :metadata
          ).compact

          if sheet.update(allowed_params)
            Success(sheet)
          else
            Failure[:persistence_error, sheet.errors.to_h]
          end
        end
      end
    end
  end
end
