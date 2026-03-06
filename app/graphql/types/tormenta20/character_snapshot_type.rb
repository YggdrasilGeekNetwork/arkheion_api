# frozen_string_literal: true

module Types
  module Tormenta20
    class CharacterSnapshotType < Types::BaseObject
      field :id, ID, null: false
      field :version, Integer, null: false
      field :checksum, String, null: false
      field :computed_at, GraphQL::Types::ISO8601DateTime, null: false

      field :computed_attributes, Types::Tormenta20::ComputedAttributesType, null: false
      field :computed_defenses, Types::Tormenta20::ComputedDefensesType, null: false
      field :computed_skills, GraphQL::Types::JSON, null: false
      field :computed_combat, Types::Tormenta20::ComputedCombatType, null: false
      field :computed_resources, Types::Tormenta20::ComputedResourcesType, null: false
      field :computed_abilities, [Types::Tormenta20::AbilityType], null: false
      field :computed_spells, Types::Tormenta20::ComputedSpellsType, null: false
      field :computed_proficiencies, Types::Tormenta20::ComputedProficienciesType, null: false

      field :pv_max, Integer, null: false
      field :pm_max, Integer, null: false

      field :stale, Boolean, null: false, method: :stale?
    end
  end
end
