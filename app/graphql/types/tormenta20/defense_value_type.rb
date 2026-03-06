# frozen_string_literal: true

module Types
  module Tormenta20
    class DefenseValueType < Types::BaseObject
      field :base, Integer, null: false
      field :total, Integer, null: false
      field :dexterity_bonus, Integer, null: true
      field :armor_bonus, Integer, null: true
      field :shield_bonus, Integer, null: true
      field :attribute_bonus, Integer, null: true
      field :other_bonuses, [BonusType], null: true
      field :condition_penalty, Integer, null: true
      field :effect_bonus, Integer, null: true
    end

    class ComputedDefensesType < Types::BaseObject
      field :defesa, DefenseValueType, null: false
      field :fortitude, DefenseValueType, null: false
      field :reflexos, DefenseValueType, null: false
      field :vontade, DefenseValueType, null: false
    end
  end
end
