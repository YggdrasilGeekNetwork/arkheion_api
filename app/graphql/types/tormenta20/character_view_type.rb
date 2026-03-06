# frozen_string_literal: true

module Types
  module Tormenta20
    class ComputedDataType < Types::BaseObject
      field :computed_attributes, ComputedAttributesType, null: false
      field :computed_defenses, ComputedDefensesType, null: false
      field :computed_skills, GraphQL::Types::JSON, null: false
      field :computed_combat, ComputedCombatType, null: false
      field :computed_resources, ComputedResourcesType, null: false
      field :computed_abilities, [AbilityType], null: false
      field :computed_spells, ComputedSpellsType, null: true
      field :computed_proficiencies, ComputedProficienciesType, null: false
      field :active_condition_effects, GraphQL::Types::JSON, null: true
    end

    class CharacterViewType < Types::BaseObject
      description "Complete character view with computed values and state"

      field :character_sheet, CharacterSheetType, null: false
      field :state, CharacterStateType, null: true
      field :computed, ComputedDataType, null: true
      field :snapshot, CharacterSnapshotType, null: true
      field :live, Boolean, null: false
    end
  end
end
