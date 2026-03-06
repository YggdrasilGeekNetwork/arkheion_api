# frozen_string_literal: true

module Tormenta20
  class CharacterStateContract < BaseContract
    params do
      optional(:current_pv).filled(:integer)
      optional(:current_pm).filled(:integer)
      optional(:temporary_pv).filled(:integer, gteq?: 0)

      optional(:equipped_items).hash(Schemas::EquippedItemsSchema)
      optional(:active_conditions).array(Schemas::ConditionSchema)
      optional(:active_effects).array(Schemas::EffectSchema)
      optional(:consumable_uses).hash
      optional(:spell_slots_used).hash(Schemas::SpellSlotsUsedSchema)
      optional(:ability_uses).hash
      optional(:inventory).array(Schemas::InventoryItemSchema)
      optional(:currency).hash(Schemas::CurrencySchema)
      optional(:notes).hash
    end
  end
end
