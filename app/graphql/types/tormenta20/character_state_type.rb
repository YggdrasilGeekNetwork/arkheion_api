# frozen_string_literal: true

module Types
  module Tormenta20
    class EquippedItemType < Types::BaseObject
      field :item_id, String, null: true
      field :item_key, String, null: true
      field :enhancements, [String], null: true
    end

    class ConditionType < Types::BaseObject
      field :condition_key, String, null: false
      field :duration, Integer, null: true
      field :duration_unit, String, null: true
      field :source, String, null: true
      field :stacks, Integer, null: true
    end

    class EffectType < Types::BaseObject
      field :effect_key, String, null: false
      field :source, String, null: false
      field :duration, Integer, null: true
      field :duration_unit, String, null: true
      field :modifiers, GraphQL::Types::JSON, null: true
    end

    class InventoryItemType < Types::BaseObject
      field :item_id, String, null: false
      field :item_key, String, null: false
      field :quantity, Integer, null: false
      field :enhancements, [String], null: true
      field :notes, String, null: true
    end

    class CurrencyType < Types::BaseObject
      field :tibares_ouro, Integer, null: false
      field :tibares_prata, Integer, null: false
      field :tibares_cobre, Integer, null: false
    end

    class CharacterStateType < Types::BaseObject
      field :id, ID, null: false
      field :current_pv, Integer, null: false
      field :current_pm, Integer, null: false
      field :temporary_pv, Integer, null: false
      field :effective_pv, Integer, null: false

      field :equipped_items, GraphQL::Types::JSON, null: false
      field :active_conditions, [ConditionType], null: false
      field :active_effects, [EffectType], null: false
      field :inventory, [InventoryItemType], null: false
      field :currency, CurrencyType, null: true

      field :spell_slots_used, GraphQL::Types::JSON, null: false
      field :ability_uses, GraphQL::Types::JSON, null: false

      field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    end
  end
end
