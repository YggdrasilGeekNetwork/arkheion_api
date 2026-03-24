# frozen_string_literal: true

module Tormenta20
  class CharacterState < ApplicationRecord
    self.table_name = "tormenta20_character_states"

    belongs_to :character_sheet,
               class_name: "Tormenta20::CharacterSheet",
               inverse_of: :character_state

    validates :character_sheet_id, uniqueness: true
    validates :current_pv, numericality: { only_integer: true }
    validates :current_pm, numericality: { only_integer: true }
    validates :temporary_pv, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

    validate :validate_equipped_items_schema
    validate :validate_active_conditions_schema
    validate :validate_active_effects_schema
    validate :validate_inventory_schema
    validate :validate_currency_schema

    def effective_pv
      current_pv + temporary_pv
    end

    def take_damage(amount)
      remaining = amount

      if temporary_pv > 0
        absorbed = [temporary_pv, remaining].min
        self.temporary_pv -= absorbed
        remaining -= absorbed
      end

      self.current_pv -= remaining
      save!
    end

    def heal(amount, max_pv:)
      self.current_pv = [current_pv + amount, max_pv].min
      save!
    end

    def spend_pm(amount)
      return false if current_pm < amount

      self.current_pm -= amount
      save!
    end

    def recover_pm(amount, max_pm:)
      self.current_pm = [current_pm + amount, max_pm].min
      save!
    end

    def rest_full(snapshot)
      self.current_pv = snapshot.pv_max
      self.current_pm = snapshot.pm_max
      self.temporary_pv = 0
      self.spell_slots_used = {}
      self.ability_uses = {}
      clear_expired_effects!
      save!
    end

    def add_condition(condition_key, **options)
      condition = { "condition_key" => condition_key }.merge(options.stringify_keys)
      self.active_conditions = active_conditions + [condition]
      save!
    end

    def remove_condition(condition_key)
      self.active_conditions = active_conditions.reject { |c| c["condition_key"] == condition_key }
      save!
    end

    def has_condition?(condition_key)
      active_conditions.any? { |c| c["condition_key"] == condition_key }
    end

    def equip_item(slot, item_data)
      self.equipped_items = equipped_items.merge(slot.to_s => item_data)
      save!
    end

    def unequip_item(slot)
      self.equipped_items = equipped_items.except(slot.to_s)
      save!
    end

    private

    def clear_expired_effects!
      self.active_effects = active_effects.reject do |effect|
        effect["duration"]&.zero?
      end

      self.active_conditions = active_conditions.reject do |condition|
        condition["duration"]&.zero?
      end
    end

    def validate_equipped_items_schema
      return if equipped_items.blank?

      result = Schemas::EquippedItemsSchema.call(equipped_items)
      return if result.success?

      result.errors.to_h.each do |field, messages|
        errors.add(:equipped_items, "#{field}: #{messages.join(', ')}")
      end
    end

    def validate_active_conditions_schema
      return if active_conditions.blank?

      active_conditions.each_with_index do |condition, idx|
        result = Schemas::ConditionSchema.call(condition)
        next if result.success?

        result.errors.to_h.each do |field, messages|
          errors.add(:active_conditions, "[#{idx}].#{field}: #{messages.join(', ')}")
        end
      end
    end

    def validate_active_effects_schema
      return if active_effects.blank?

      active_effects.each_with_index do |effect, idx|
        result = Schemas::EffectSchema.call(effect)
        next if result.success?

        result.errors.to_h.each do |field, messages|
          errors.add(:active_effects, "[#{idx}].#{field}: #{messages.join(', ')}")
        end
      end
    end

    def validate_inventory_schema
      return if inventory.blank?

      inventory.each_with_index do |item, idx|
        result = Schemas::InventoryItemSchema.call(item)
        next if result.success?

        result.errors.to_h.each do |field, messages|
          errors.add(:inventory, "[#{idx}].#{field}: #{messages.join(', ')}")
        end
      end
    end

    def validate_currency_schema
      return if currency.blank?

      result = Schemas::CurrencySchema.call(currency)
      return if result.success?

      result.errors.to_h.each do |field, messages|
        errors.add(:currency, "#{field}: #{messages.join(', ')}")
      end
    end
  end
end
