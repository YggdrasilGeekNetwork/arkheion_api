# frozen_string_literal: true

module Mutations
  module Tormenta20
    class LevelUpCharacter < BaseMutation
      argument :id,    ID, required: true
      argument :input, Types::Tormenta20::Inputs::LevelUpCharacterInput, required: true

      field :character, Types::Tormenta20::CharacterType, null: true
      field :errors,    [String], null: true

      def resolve(id:, input:)
        require_authentication!

        result = ::Tormenta20::Operations::Characters::LevelUp.new.call(
          id: id,
          params: input.to_h,
          user: current_user
        )

        handle_result(result)
      end
    end
  end
end
