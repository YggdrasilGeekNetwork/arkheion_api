# frozen_string_literal: true

module Mutations
  module Tormenta20
    class GenerateSnapshot < BaseMutation
      argument :character_sheet_id, ID, required: true
      argument :force, Boolean, required: false, default_value: false

      field :snapshot, Types::Tormenta20::CharacterSnapshotType, null: true
      field :cached, Boolean, null: true
      field :errors, [String], null: true

      def resolve(character_sheet_id:, force:)
        require_authentication!

        sheet = find_character_sheet!(character_sheet_id)

        result = ::Tormenta20::Actions::Snapshots::Generate.call(
          character_sheet: sheet,
          force: force
        )

        handle_result(result)
      end
    end
  end
end
