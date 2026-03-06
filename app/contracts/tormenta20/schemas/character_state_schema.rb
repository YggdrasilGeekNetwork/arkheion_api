# frozen_string_literal: true

module Tormenta20
  module Schemas
    EquippedItemsSchema = Dry::Schema.JSON do
      optional(:main_hand).hash do
        optional(:item_id).filled(:string)
        optional(:item_key).filled(:string)
        optional(:enhancements).array(:string)
      end

      optional(:off_hand).hash do
        optional(:item_id).filled(:string)
        optional(:item_key).filled(:string)
        optional(:enhancements).array(:string)
      end

      optional(:armor).hash do
        optional(:item_id).filled(:string)
        optional(:item_key).filled(:string)
        optional(:enhancements).array(:string)
      end

      optional(:shield).hash do
        optional(:item_id).filled(:string)
        optional(:item_key).filled(:string)
        optional(:enhancements).array(:string)
      end

      optional(:accessories).array do
        hash do
          required(:slot).filled(:string)
          required(:item_id).filled(:string)
          optional(:item_key).filled(:string)
          optional(:enhancements).array(:string)
        end
      end
    end

    ConditionSchema = Dry::Schema.JSON do
      required(:condition_key).filled(:string)
      optional(:duration).filled(:integer)
      optional(:duration_unit).filled(:string)
      optional(:source).filled(:string)
      optional(:stacks).filled(:integer, gteq?: 1)
      optional(:extra_data).hash
    end

    EffectSchema = Dry::Schema.JSON do
      required(:effect_key).filled(:string)
      required(:source).filled(:string)
      optional(:duration).filled(:integer)
      optional(:duration_unit).filled(:string)
      optional(:modifiers).hash
      optional(:extra_data).hash
    end

    InventoryItemSchema = Dry::Schema.JSON do
      required(:item_id).filled(:string)
      required(:item_key).filled(:string)
      required(:quantity).filled(:integer, gteq?: 1)
      optional(:enhancements).array(:string)
      optional(:notes).filled(:string)
      optional(:extra_data).hash
    end

    CurrencySchema = Dry::Schema.JSON do
      optional(:tibares_ouro).filled(:integer, gteq?: 0)
      optional(:tibares_prata).filled(:integer, gteq?: 0)
      optional(:tibares_cobre).filled(:integer, gteq?: 0)
    end

    AbilityUsesSchema = Dry::Schema.JSON do
      # Dynamic keys for ability usage tracking
      # Format: ability_key => { used: integer, max: integer }
    end

    SpellSlotsUsedSchema = Dry::Schema.JSON do
      optional(:circle_1).filled(:integer, gteq?: 0)
      optional(:circle_2).filled(:integer, gteq?: 0)
      optional(:circle_3).filled(:integer, gteq?: 0)
      optional(:circle_4).filled(:integer, gteq?: 0)
      optional(:circle_5).filled(:integer, gteq?: 0)
    end
  end
end
