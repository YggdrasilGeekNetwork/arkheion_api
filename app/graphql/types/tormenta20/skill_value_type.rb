# frozen_string_literal: true

module Types
  module Tormenta20
    class SkillValueType < Types::BaseObject
      field :ranks, Integer, null: false
      field :attribute, String, null: false
      field :attribute_modifier, Integer, null: false
      field :trained, Boolean, null: false
      field :training_bonus, Integer, null: false
      field :other_bonuses, [BonusType], null: true
      field :total, Integer, null: false
      field :condition_penalty, Integer, null: true
      field :effect_bonus, Integer, null: true
    end
  end
end
