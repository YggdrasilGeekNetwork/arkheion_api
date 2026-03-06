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
            weapons: compile_weapons(context, computed_attributes, bab, melee_bonuses, ranged_bonuses)
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

        def collect_attack_bonuses(context, type)
          bonuses = []

          power_keys = collect_all_power_keys(context)

          power_keys.each do |power_key|
            poder = power_definition(power_key)
            next unless poder

            effects = poder.effects
            next unless effects.is_a?(Array)

            effects.each do |effect|
              next unless effect.is_a?(Hash)
              next unless effect["type"] == "attack_improvement"
              next unless passive_effect?(effect)
              next unless applies_to?(effect, type)

              value = effect["value"]
              next unless value.is_a?(Integer)

              bonuses << { label: poder.name, value: value }
            end
          end

          bonuses
        end

        def collect_all_power_keys(context)
          keys = []

          context.level_ups.each do |level_up|
            keys.concat(level_up.abilities_chosen["class_abilities"] || [])
            keys.concat(level_up.abilities_chosen["bonus_abilities"] || [])
            level_up.powers_chosen.each_value { |v| keys.concat(v || []) }
          end

          race = race_definition(context.character_sheet.race_key)
          keys.concat(race&.racial_abilities || [])
          keys.concat(context.character_sheet.race_choices["chosen_abilities"] || [])
          keys.concat(context.character_sheet.origin_choices["chosen_powers"] || [])

          keys.uniq
        end

        def passive_effect?(effect)
          d = effect["duration"].to_s
          d.empty? || d.start_with?("permanente")
        end

        def applies_to?(effect, type)
          weapon_req = effect.dig("requirements", "weapon")
          return true unless weapon_req

          case type
          when :melee  then weapon_req.include?("corpo")
          when :ranged then weapon_req.include?("distancia") || weapon_req.include?("arremesso")
          else true
          end
        end

        def compile_weapons(context, computed_attributes, bab, melee_bonuses, ranged_bonuses)
          state = context.state
          return [] unless state

          weapons = []

          %w[main_hand off_hand].each do |slot|
            item_data = state.equipped_items[slot]
            next unless item_data&.dig("item_key")

            weapon = build_weapon_entry(item_data, computed_attributes, bab, slot == "off_hand", melee_bonuses, ranged_bonuses)
            weapons << weapon if weapon
          end

          weapons
        end

        def build_weapon_entry(item_data, computed_attributes, bab, off_hand, melee_bonuses, ranged_bonuses)
          item_key = item_data["item_key"]
          weapon   = weapon_definition(item_key)
          return nil unless weapon

          attr_key     = weapon.ranged? ? "destreza" : "forca"
          attr_mod     = computed_attributes.dig(attr_key, :modifier) || 0
          power_bonus  = sum_bonuses(weapon.ranged? ? ranged_bonuses : melee_bonuses)

          {
            id: "#{off_hand ? 'off_hand' : 'main_hand'}_#{item_key}",
            name: weapon.name,
            damage: weapon.damage || "1d4",
            damage_type: weapon.damage_type,
            attack_bonus: bab + attr_mod + power_bonus,
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
