# frozen_string_literal: true

module Mutations
  module Tormenta20
    class CreateCharacter < BaseMutation
      argument :input, Types::Tormenta20::Inputs::CreateCharacterInput, required: true

      field :character, Types::Tormenta20::CharacterType, null: true
      field :errors,    [String], null: true

      def resolve(input:)
        require_authentication!

        result = ::Tormenta20::Operations::Characters::Create.new.call(
          params: input.to_h,
          user: current_user
        )

        handle_result(result)
      end
    end
  end
end
