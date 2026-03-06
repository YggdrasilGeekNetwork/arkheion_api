# frozen_string_literal: true

module Types
  module Tormenta20
    class KnownSpellType < Types::BaseObject
      field :spell_key, String, null: false
      field :circle, Integer, null: false
      field :school, String, null: true
      field :learned_at_level, Integer, null: true
      field :class_key, String, null: true
    end

    class SpellSlotType < Types::BaseObject
      field :circle, Integer, null: false
      field :total, Integer, null: false
      field :used, Integer, null: false
      field :remaining, Integer, null: false
    end

    class SpellSaveDcType < Types::BaseObject
      field :base, Integer, null: false
      field :attribute_modifier, Integer, null: false
      field :total, Integer, null: false
    end

    class ComputedSpellsType < Types::BaseObject
      field :known_spells, [KnownSpellType], null: false
      field :spell_slots, GraphQL::Types::JSON, null: false
      field :save_dc, SpellSaveDcType, null: true
      field :spellcasting_attribute, String, null: true
    end
  end
end
