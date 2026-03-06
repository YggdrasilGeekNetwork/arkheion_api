# frozen_string_literal: true

module Tormenta20
  module Actions
    class LevelUpCharacter < BaseAction
      def call(character_sheet_id:, params:, user:)
        sheet = yield find_sheet(character_sheet_id, user)
        yield authorize!(user: user, resource: sheet, action: :update)
        yield validate_can_level_up(sheet)

        result = yield with_transaction {
          level_params = params.merge(level: sheet.current_level + 1)
          Interactions::LevelUps::Create.call(character_sheet: sheet, params: level_params)
        }

        # Regenerate snapshot after level up
        yield Interactions::Snapshots::Generate.call(character_sheet: sheet.reload, force: true)

        # Update max resources if they increased
        yield update_resources_after_level_up(sheet)

        broadcast(:character_leveled_up, {
          character_id: sheet.id,
          new_level: sheet.current_level,
          class_key: params[:class_key]
        })

        Success(
          character_sheet: sheet.reload,
          level_up: result[:level_up]
        )
      end

      private

      def find_sheet(id, user)
        sheet = CharacterSheet.find_by(id: id, user_id: user.id)

        if sheet
          Success(sheet)
        else
          Failure(error: :not_found, message: "Character sheet not found")
        end
      end

      def validate_can_level_up(sheet)
        if sheet.current_level >= 20
          Failure(error: :max_level, message: "Character is already at maximum level")
        else
          Success(true)
        end
      end

      def update_resources_after_level_up(sheet)
        snapshot_result = Interactions::Snapshots::Generate.call(character_sheet: sheet)
        return snapshot_result if snapshot_result.failure?

        snapshot = snapshot_result.value![:snapshot]
        state = sheet.character_state

        # Increase current resources by the difference (new max - old current)
        pv_increase = [snapshot.pv_max - state.current_pv, 0].max
        pm_increase = [snapshot.pm_max - state.current_pm, 0].max

        state.update!(
          current_pv: state.current_pv + pv_increase,
          current_pm: state.current_pm + pm_increase
        )

        Success(state)
      end
    end
  end
end
