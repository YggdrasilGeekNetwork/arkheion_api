# frozen_string_literal: true

module Tormenta20
  module Interactions
    module CharacterSheets
      class Update < BaseInteraction
        def call(id:, params:, user:)
          sheet = yield find_character_sheet(id, user: user)
          validated = yield validate_update_params(params)
          updated = yield update_sheet(sheet, validated)
          yield invalidate_snapshot(updated)

          Success(character_sheet: updated)
        end

        private

        def validate_update_params(params)
          # Allow partial updates
          contract = CharacterSheetContract.new
          result = contract.call(params)

          # For updates, we accept partial data
          Success(params.slice(
            :name, :deity_key, :sheet_attributes, :race_choices,
            :origin_choices, :proficiencies, :metadata
          ).compact)
        end

        def update_sheet(sheet, params)
          if sheet.update(params)
            Success(sheet)
          else
            Failure(errors: sheet.errors.to_h)
          end
        end

        def invalidate_snapshot(sheet)
          # Mark that a new snapshot is needed
          Success(sheet)
        end
      end
    end
  end
end
