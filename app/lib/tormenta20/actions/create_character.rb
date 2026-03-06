# frozen_string_literal: true

module Tormenta20
  module Actions
    class CreateCharacter < BaseAction
      def call(params:, user:)
        yield authorize!(user: user, resource: CharacterSheet, action: :create)

        result = yield with_transaction do
          Interactions::CharacterSheets::Create.call(params: params, user: user)
        end

        sheet = result[:character_sheet]

        # Generate initial snapshot
        yield Interactions::Snapshots::Generate.call(character_sheet: sheet, force: true)

        # Initialize state with max resources
        yield initialize_state(sheet)

        broadcast(:character_created, { character_id: sheet.id, user_id: user.id })

        Success(character_sheet: sheet.reload)
      end

      private

      def initialize_state(sheet)
        snapshot_result = Interactions::Snapshots::Generate.call(character_sheet: sheet)
        return snapshot_result if snapshot_result.failure?

        snapshot = snapshot_result.value![:snapshot]
        state = sheet.character_state

        state.update!(
          current_pv: snapshot.pv_max,
          current_pm: snapshot.pm_max
        )

        Success(state)
      end
    end
  end
end
