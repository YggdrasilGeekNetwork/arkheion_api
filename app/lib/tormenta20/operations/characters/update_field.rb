# frozen_string_literal: true

module Tormenta20
  module Operations
    module Characters
      # Generic operation for all granular character update mutations.
      # Accepts sheet_updates (columns on character_sheets) and/or
      # state_updates (columns on character_states).
      class UpdateField < BaseOperation
        def call(id:, user:, sheet_updates: {}, state_updates: {})
          sheet = step find_character_sheet(id, user: user)
          step apply_sheet_updates(sheet, sheet_updates) if sheet_updates.present?
          step apply_state_updates(sheet, state_updates) if state_updates.present?
          step increment_version(sheet)

          Success(character: Presenters::CharacterPresenter.new(sheet.reload))
        end

        private

        def apply_sheet_updates(sheet, updates)
          sheet.assign_attributes(updates)
          if sheet.save
            Success(sheet)
          else
            Failure[:persistence_error, sheet.errors.to_h]
          end
        end

        def apply_state_updates(sheet, updates)
          state = sheet.character_state
          return Failure[:not_found, 'Character state not found'] unless state

          state.assign_attributes(updates)
          if state.save
            Success(state)
          else
            Failure[:persistence_error, state.errors.to_h]
          end
        end

        def increment_version(sheet)
          sheet.reload.increment!(:character_version)
          Success(sheet)
        end
      end
    end
  end
end
