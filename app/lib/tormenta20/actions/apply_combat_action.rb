# frozen_string_literal: true

module Tormenta20
  module Actions
    class ApplyCombatAction < BaseAction
      def call(character_sheet_id:, action_type:, params:, user:)
        sheet = yield find_sheet(character_sheet_id, user)
        yield authorize!(user: user, resource: sheet, action: :update)

        result = yield case action_type.to_sym
                       when :damage
                         apply_damage(sheet, params)
                       when :heal
                         apply_healing(sheet, params)
                       when :spend_pm
                         spend_pm(sheet, params)
                       when :recover_pm
                         recover_pm(sheet, params)
                       else
                         Failure(error: :invalid_action, message: "Unknown action: #{action_type}")
                       end

        broadcast(:combat_action_applied, {
          character_id: sheet.id,
          action_type: action_type,
          params: params
        })

        Success(result)
      end

      private

      def find_sheet(id, user)
        sheet = CharacterSheet.find_by(id: id, user_id: user.id)

        if sheet
          Success(sheet)
        else
          Failure(error: :not_found)
        end
      end

      def apply_damage(sheet, params)
        Interactions::CharacterState::ApplyDamage.call(
          character_sheet: sheet,
          amount: params[:amount].to_i,
          damage_type: params[:damage_type],
          source: params[:source]
        )
      end

      def apply_healing(sheet, params)
        Interactions::CharacterState::ApplyHealing.call(
          character_sheet: sheet,
          amount: params[:amount].to_i,
          source: params[:source]
        )
      end

      def spend_pm(sheet, params)
        state = sheet.character_state
        amount = params[:amount].to_i

        if state.spend_pm(amount)
          Success(state: state, pm_spent: amount, current_pm: state.current_pm)
        else
          Failure(error: :insufficient_pm, message: "Not enough PM")
        end
      end

      def recover_pm(sheet, params)
        snapshot_result = Interactions::Snapshots::Generate.call(character_sheet: sheet)
        return snapshot_result if snapshot_result.failure?

        snapshot = snapshot_result.value![:snapshot]
        state = sheet.character_state
        amount = params[:amount].to_i

        state.recover_pm(amount, max_pm: snapshot.pm_max)
        Success(state: state, pm_recovered: amount, current_pm: state.current_pm)
      end
    end
  end
end
