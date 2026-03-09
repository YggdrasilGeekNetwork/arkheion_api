# frozen_string_literal: true

module Mutations
  module Tormenta20
    class UpdateCharacterAttributes < BaseMutation
      argument :id,         ID, required: true
      argument :attributes, [Types::Tormenta20::Inputs::AttributeInput], required: true

      field :character, Types::Tormenta20::CharacterType, null: true
      field :errors,    [String], null: true

      def resolve(id:, attributes:)
        require_authentication!

        result = ::Tormenta20::Actions::Characters::UpdateField.call(
          id: id,
          user: current_user,
          sheet_updates: { attributes_data: attributes.map(&:to_h) }
        )

        handle_result(result)
      end
    end
  end
end
