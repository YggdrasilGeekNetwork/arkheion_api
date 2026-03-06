# frozen_string_literal: true

module Types
  module Tormenta20
    class BonusType < Types::BaseObject
      field :source, String, null: false
      field :value, Integer, null: false
    end

    class AttributeValueType < Types::BaseObject
      field :base, Integer, null: false
      field :total, Integer, null: false
      field :modifier, Integer, null: false
      field :bonuses, [BonusType], null: true
      field :condition_penalty, Integer, null: true
      field :effect_bonus, Integer, null: true
    end
  end
end
