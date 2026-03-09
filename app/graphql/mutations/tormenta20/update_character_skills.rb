# frozen_string_literal: true

module Mutations
  module Tormenta20
    class UpdateCharacterSkills < BaseMutation
      argument :id,     ID, required: true
      argument :skills, [Types::Tormenta20::Inputs::SkillInput], required: true

      field :character, Types::Tormenta20::CharacterType, null: true
      field :errors,    [String], null: true

      def resolve(id:, skills:)
        require_authentication!

        result = ::Tormenta20::Actions::Characters::UpdateField.call(
          id: id,
          user: current_user,
          sheet_updates: { skills_data: skills.map(&:to_h) }
        )

        handle_result(result)
      end
    end
  end
end
