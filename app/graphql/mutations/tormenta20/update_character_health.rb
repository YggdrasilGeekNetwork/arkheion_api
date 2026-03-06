# frozen_string_literal: true

module Mutations
  module Tormenta20
    class UpdateCharacterHealth < BaseMutation
      argument :id,     ID,      required: true
      argument :health, Integer, required: true

      field :character, Types::Tormenta20::CharacterType, null: true
      field :errors,    [String], null: true

      def resolve(id:, health:)
        require_authentication!

        result = ::Tormenta20::Operations::Characters::UpdateField.new.call(
          id: id,
          user: current_user,
          state_updates: { current_pv: health }
        )

        handle_result(result)
      end
    end
  end
end
