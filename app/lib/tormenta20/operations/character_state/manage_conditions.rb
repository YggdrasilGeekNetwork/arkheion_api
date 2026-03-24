# frozen_string_literal: true

module Tormenta20
  module Operations
    module CharacterState
      class ManageConditions < BaseOperation
        def call(character_sheet:, action:, condition_key:, **options)
          state = character_sheet.character_state
          return Failure[:not_found, "State not found"] unless state

          case action.to_sym
          when :add
            add_condition(state, condition_key, options)
          when :remove
            remove_condition(state, condition_key)
          when :check
            check_condition(state, condition_key)
          else
            Failure[:invalid_action, "Unknown action: #{action}"]
          end
        end

        private

        def add_condition(state, condition_key, options)
          state.add_condition(condition_key, **options)
          Success(
            state: state,
            condition_added: condition_key,
            active_conditions: state.active_conditions
          )
        end

        def remove_condition(state, condition_key)
          had_condition = state.has_condition?(condition_key)
          state.remove_condition(condition_key)

          Success(
            state: state,
            condition_removed: condition_key,
            was_active: had_condition,
            active_conditions: state.active_conditions
          )
        end

        def check_condition(state, condition_key)
          Success(
            has_condition: state.has_condition?(condition_key),
            active_conditions: state.active_conditions
          )
        end
      end
    end
  end
end
