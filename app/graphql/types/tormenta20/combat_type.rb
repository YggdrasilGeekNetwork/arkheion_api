# frozen_string_literal: true

module Types
  module Tormenta20
    class AttackValueType < Types::BaseObject
      field :total, Integer, null: false
      field :attribute, String, null: false
      field :attribute_modifier, Integer, null: false
      field :other_bonuses, [BonusType], null: true
      field :condition_penalty, Integer, null: true
      field :effect_bonus, Integer, null: true
    end

    class WeaponType < Types::BaseObject
      field :name, String, null: false
      field :attack_bonus, Integer, null: false
      field :damage, String, null: false
      field :critical, String, null: false
      field :damage_type, String, null: true
      field :range, String, null: true
      field :properties, [String], null: true
    end

    class ComputedCombatType < Types::BaseObject
      field :base_attack_bonus, Integer, null: false
      field :melee_attack, AttackValueType, null: false
      field :ranged_attack, AttackValueType, null: false
      field :weapons, [WeaponType], null: true
    end
  end
end
