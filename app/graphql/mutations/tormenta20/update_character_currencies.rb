# frozen_string_literal: true

module Mutations
  module Tormenta20
    class UpdateCharacterCurrencies < BaseMutation
      argument :id,         ID, required: true
      argument :currencies, Types::Tormenta20::Inputs::CurrenciesInput, required: true

      field :character, Types::Tormenta20::CharacterType, null: true
      field :errors,    [String], null: true

      def resolve(id:, currencies:)
        require_authentication!

        result = ::Tormenta20::Operations::Characters::UpdateField.new.call(
          id: id,
          user: current_user,
          state_updates: { currencies_data: currencies.to_h }
        )

        handle_result(result)
      end
    end
  end
end
