# frozen_string_literal: true

module Mutations
  module Tormenta20
    class ApplyCombatAction < BaseMutation
      argument :character_sheet_id, ID, required: true
      argument :input, Types::Tormenta20::Inputs::CombatActionInput, required: true

      field :state, Types::Tormenta20::CharacterStateType, null: true
      field :damage_taken, Integer, null: true
      field :healing_received, Integer, null: true
      field :current_pv, Integer, null: true
      field :current_pm, Integer, null: true
      field :is_dying, Boolean, null: true
      field :errors, [String], null: true

      def resolve(character_sheet_id:, input:)
        require_authentication!

        sheet = find_character_sheet!(character_sheet_id)

        result = case input[:action_type].to_sym
                 when :damage
                   ::Tormenta20::Operations::CharacterState::ApplyDamage.new.call(
                     character_sheet: sheet,
                     amount: input[:amount].to_i,
                     damage_type: input[:damage_type],
                     source: input[:source]
                   )
                 when :heal
                   ::Tormenta20::Operations::CharacterState::ApplyHealing.new.call(
                     character_sheet: sheet,
                     amount: input[:amount].to_i,
                     source: input[:source]
                   )
                 else
                   raise GraphQL::ExecutionError, "Unknown action type: #{input[:action_type]}"
                 end

        handle_result(result)
      end
    end
  end
end
