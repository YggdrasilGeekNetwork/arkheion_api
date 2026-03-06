# frozen_string_literal: true

module Types
  module Tormenta20
    class ResourceValueType < Types::BaseObject
      field :base, Integer, null: false
      field :max, Integer, null: false
      field :constitution_bonus, Integer, null: true
      field :attribute_bonus, Integer, null: true
      field :other_bonuses, [BonusType], null: true
    end

    class MovementValueType < Types::BaseObject
      field :base, Integer, null: false
      field :total, Integer, null: false
      field :armor_penalty, Integer, null: true
      field :other_bonuses, [BonusType], null: true
    end

    class ComputedResourcesType < Types::BaseObject
      field :pv, ResourceValueType, null: false
      field :pm, ResourceValueType, null: false
      field :deslocamento, MovementValueType, null: false
    end
  end
end
