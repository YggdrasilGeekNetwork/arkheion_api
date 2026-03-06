# frozen_string_literal: true

module Mutations
  module Tormenta20
    class LevelUp < BaseMutation
      argument :character_sheet_id, ID, required: true
      argument :input, Types::Tormenta20::Inputs::LevelUpInput, required: true

      field :character_sheet, Types::Tormenta20::CharacterSheetType, null: true
      field :level_up, Types::Tormenta20::LevelUpType, null: true
      field :errors, [String], null: true

      def resolve(character_sheet_id:, input:)
        require_authentication!

        result = ::Tormenta20::Operations::LevelUps::Add.new.call(
          character_sheet_id: character_sheet_id,
          params: input.to_h,
          user: current_user
        )

        handle_result(result)
      end
    end
  end
end
