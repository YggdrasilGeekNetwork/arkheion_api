# frozen_string_literal: true

module Tormenta20
  module Pipeline
    module Pipes
      class ApplyEquipmentModifiers < BasePipe
        def call(context)
          state = context.state
          return context unless state&.equipped_items.present?

          apply_armor_modifiers(context, state)
          apply_shield_modifiers(context, state)
          apply_weapon_modifiers(context, state)

          context
        end

        private

        def apply_armor_modifiers(context, state)
          armor_key = state.equipped_items.dig("armor", "item_key")
          return unless armor_key

          armor = armor_definition(armor_key)
          return unless armor

          defenses = context[:computed_defenses] || {}
          defesa = (defenses[:defesa] || {}).dup

          defesa[:armor_bonus] = armor.defense_bonus
          defesa[:total] = (defesa[:base] || 10) +
                           (defesa[:dexterity_bonus] || 0) +
                           armor.defense_bonus +
                           (defesa[:shield_bonus] || 0) +
                           sum_bonuses(defesa[:other_bonuses] || [])

          context[:computed_defenses] = defenses.merge(defesa: defesa)
          context[:equipped_armor] = { key: armor_key, name: armor.name, data: armor.to_h }
        end

        def apply_shield_modifiers(context, state)
          shield_key = state.equipped_items.dig("shield", "item_key")
          return unless shield_key

          shield = shield_definition(shield_key)
          return unless shield

          defenses = context[:computed_defenses] || {}
          defesa = (defenses[:defesa] || {}).dup

          defesa[:shield_bonus] = shield.defense_bonus
          defesa[:total] = (defesa[:base] || 10) +
                           (defesa[:dexterity_bonus] || 0) +
                           (defesa[:armor_bonus] || 0) +
                           shield.defense_bonus +
                           sum_bonuses(defesa[:other_bonuses] || [])

          context[:computed_defenses] = defenses.merge(defesa: defesa)
          context[:equipped_shield] = { key: shield_key, name: shield.name, data: shield.to_h }
        end

        def apply_weapon_modifiers(context, state)
          %w[main_hand off_hand].each do |slot|
            weapon_key = state.equipped_items.dig(slot, "item_key")
            next unless weapon_key

            weapon = weapon_definition(weapon_key)
            next unless weapon

            context["equipped_#{slot}"] = { key: weapon_key, name: weapon.name, data: weapon.to_h }
          end
        end
      end
    end
  end
end
