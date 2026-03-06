# frozen_string_literal: true

module Mutations
  module Tormenta20
    class UpdateCharacter < BaseMutation
      argument :id, ID, required: true
      argument :input, Types::Tormenta20::Inputs::CharacterSheetUpdateInput, required: true

      field :character_sheet, Types::Tormenta20::CharacterSheetType, null: true
      field :errors, [String], null: true

      def resolve(id:, input:)
        require_authentication!

        result = ::Tormenta20::Operations::CharacterSheets::Update.new.call(
          id: id,
          params: input.to_h,
          user: current_user
        )

        handle_result(result)
      end
    end
  end
end
