# frozen_string_literal: true

module Mutations
  module Tormenta20
    class UpdateCharacterDefenses < BaseMutation
      argument :id,       ID, required: true
      argument :defenses, [Types::Tormenta20::Inputs::DefenseInput], required: true

      field :character, Types::Tormenta20::CharacterType, null: true
      field :errors,    [String], null: true

      def resolve(id:, defenses:)
        require_authentication!

        result = ::Tormenta20::Operations::Characters::UpdateField.new.call(
          id: id,
          user: current_user,
          sheet_updates: { defenses_data: defenses.map(&:to_h) }
        )

        handle_result(result)
      end
    end
  end
end
