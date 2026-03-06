# frozen_string_literal: true

module Tormenta20
  class LevelUpContract < BaseContract
    params do
      required(:level).filled(:integer)
      required(:class_key).filled(:string)

      optional(:class_choices).hash(Schemas::ClassChoicesSchema)
      optional(:skill_points).hash(Schemas::SkillPointsSchema)
      optional(:abilities_chosen).hash(Schemas::AbilitiesChosenSchema)
      optional(:powers_chosen).hash(Schemas::PowersChosenSchema)
      optional(:spells_chosen).hash(Schemas::SpellsChosenSchema)
      optional(:metadata).hash
    end

    rule(:level).validate(:valid_level)
  end
end
