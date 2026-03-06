# frozen_string_literal: true

module Tormenta20
  module Pipeline
    module Pipes
      class ComputeCombat < BasePipe
        FULL_BAB_CLASSES = %w[guerreiro barbaro paladino ranger].freeze
        POOR_BAB_CLASSES = %w[arcanista feiticeiro].freeze

        def call(context)
          computed_attributes = context[:computed_attributes]

          bab = calculate_base_attack_bonus(context)

          str_mod = computed_attributes.dig("forca", :modifier) || 0
          dex_mod = computed_attributes.dig("destreza", :modifier) || 0

          melee_bonuses  = collect_attack_bonuses(context, :melee)
          ranged_bonuses = collect_attack_bonuses(context, :ranged)

          context[:computed_combat] = {
            base_attack_bonus: bab,
            melee_attack: {
              total: bab + str_mod + sum_bonuses(melee_bonuses),
              attribute: "forca",
              attribute_modifier: str_mod,
              other_bonuses: melee_bonuses
            },
            ranged_attack: {
              total: bab + dex_mod + sum_bonuses(ranged_bonuses),
              attribute: "destreza",
              attribute_modifier: dex_mod,
              other_bonuses: ranged_bonuses
            },
            weapons: compile_weapons(context, computed_attributes, bab)
          }

          context
        end

        private

        def calculate_base_attack_bonus(context)
          bab = 0.0
          context.level_ups.each do |level_up|
            classe = class_definition(level_up.class_key)
            bab += bab_per_level(classe)
          end
          bab.floor
        end

        def bab_per_level(classe)
          return 0.75 unless classe

          if FULL_BAB_CLASSES.include?(classe.id)
            1.0
          elsif POOR_BAB_CLASSES.include?(classe.id)
            0.5
          else
            0.75
          end
        end

        def collect_attack_bonuses(_context, _type)
          []
        end

        def compile_weapons(context, computed_attributes, bab)
          state = context.state
          return [] unless state

          weapons = []

          %w[main_hand off_hand].each do |slot|
            item_data = state.equipped_items[slot]
            next unless item_data&.dig("item_key")

            weapon = build_weapon_entry(item_data, computed_attributes, bab, slot == "off_hand")
            weapons << weapon if weapon
          end

          weapons
        end

        def build_weapon_entry(item_data, computed_attributes, bab, off_hand)
          item_key = item_data["item_key"]
          weapon   = weapon_definition(item_key)
          return nil unless weapon

          attr_key = weapon.ranged? ? "destreza" : "forca"
          attr_mod = computed_attributes.dig(attr_key, :modifier) || 0

          {
            id: "#{off_hand ? 'off_hand' : 'main_hand'}_#{item_key}",
            name: weapon.name,
            damage: weapon.damage || "1d4",
            damage_type: weapon.damage_type,
            attack_bonus: bab + attr_mod,
            attack_attribute: attr_key,
            crit_range: weapon.critical,
            range: weapon.range,
            action_type: "standard",
            equipment_id: item_key
          }
        end
      end
    end
  end
end
