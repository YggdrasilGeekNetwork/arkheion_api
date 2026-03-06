# frozen_string_literal: true

module Tormenta20
  module Operations
    module CharacterView
      class Get < BaseOperation
        def call(character_sheet_id:, user:, live: true)
          sheet = step find_character_sheet(character_sheet_id, user: user)
          step authorize!(user: user, resource: sheet, action: :read)

          if live
            computed = step Snapshots::ComputeLive.new.call(character_sheet: sheet)

            Success(
              character_sheet: sheet,
              state: sheet.character_state,
              computed: computed[:computed_data],
              live: true
            )
          else
            snapshot_result = step Snapshots::Generate.new.call(character_sheet: sheet)

            Success(
              character_sheet: sheet,
              state: sheet.character_state,
              snapshot: snapshot_result[:snapshot],
              live: false
            )
          end
        end
      end
    end
  end
end
