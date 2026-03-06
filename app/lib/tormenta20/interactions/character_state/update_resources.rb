# frozen_string_literal: true

module Tormenta20
  module Interactions
    module CharacterState
      class UpdateResources < BaseInteraction
        def call(character_sheet:, pv: nil, pm: nil, temporary_pv: nil)
          state = character_sheet.character_state
          return Failure(error: :not_found, message: 'State not found') unless state

          updates = {}
          updates[:current_pv] = pv if pv
          updates[:current_pm] = pm if pm
          updates[:temporary_pv] = temporary_pv if temporary_pv

          if state.update(updates)
            Success(state: state)
          else
            Failure(errors: state.errors.to_h)
          end
        end
      end
    end
  end
end
