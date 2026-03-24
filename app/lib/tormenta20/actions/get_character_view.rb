# frozen_string_literal: true

module Tormenta20
  module Actions
    class GetCharacterView < BaseAction
      def call(character_sheet_id:, user:, live: true)
        sheet = yield find_sheet(character_sheet_id, user)
        yield authorize!(user: user, resource: sheet, action: :read)

        if live
          # Compute with current state (conditions, equipment, etc.)
          computed = yield Interactions::Snapshots::ComputeLive.call(character_sheet: sheet)

          Success(
            character_sheet: sheet,
            state: sheet.character_state,
            computed: computed[:computed_data],
            live: true
          )
        else
          # Return cached snapshot
          snapshot_result = yield Interactions::Snapshots::Generate.call(character_sheet: sheet)

          Success(
            character_sheet: sheet,
            state: sheet.character_state,
            snapshot: snapshot_result[:snapshot],
            live: false
          )
        end
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
    end
  end
end
