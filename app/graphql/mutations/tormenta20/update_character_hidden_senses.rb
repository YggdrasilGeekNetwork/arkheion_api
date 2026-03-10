# frozen_string_literal: true

module Mutations
  module Tormenta20
    class UpdateCharacterHiddenSenses < BaseMutation
      argument :id,                ID,       required: true
      argument :hidden_sense_names, [String], required: true

      field :character, Types::Tormenta20::CharacterType, null: true
      field :errors,    [String], null: true

      def resolve(id:, hidden_sense_names:)
        require_authentication!

        sheet = ::Tormenta20::CharacterSheet.find_by(id: id)
        return { character: nil, errors: ["Personagem não encontrado"] } unless sheet
        return { character: nil, errors: ["Acesso negado"] } unless sheet.user_id == current_user.id

        sheet.update!(hidden_senses: hidden_sense_names)

        presenter = ::Tormenta20::Presenters::CharacterPresenter.new(sheet.reload)
        { character: presenter, errors: nil }
      rescue ActiveRecord::RecordInvalid => e
        { character: nil, errors: [e.message] }
      end
    end
  end
end
