# frozen_string_literal: true

module Tormenta20
  module Pipeline
    module Pipes
      class ComputeResources < BasePipe
        ATTR_MAP = {
          "for" => "forca", "des" => "destreza", "con" => "constituicao",
          "int" => "inteligencia", "sab" => "sabedoria", "car" => "carisma"
        }.freeze

        def call(context)
          computed_attributes = context[:computed_attributes]

          context[:computed_resources] = {
            pv: compute_pv(context, computed_attributes),
            pm: compute_pm(context, computed_attributes),
            deslocamento: compute_movement(context)
          }

          context
        end

        private

        def compute_pv(context, computed_attributes)
          con_mod = computed_attributes.dig("constituicao", :modifier) || 0

          base = 0
          other_bonuses = collect_pv_bonuses(context, computed_attributes)

          context.level_ups.each do |level_up|
            classe = class_definition(level_up.class_key)

            if level_up.level == 1
              base += (classe&.initial_hp || 8) + con_mod
            else
              base += (classe&.hp_per_level || 4) + con_mod
            end
          end

          total = base + sum_bonuses(other_bonuses)

          {
            base: base,
            other_bonuses: other_bonuses,
            max: [total, 1].max
          }
        end

        def compute_pm(context, computed_attributes)
          base = 0
          attr_bonus = 0
          other_bonuses = collect_pm_bonuses(context, computed_attributes)

          context.level_ups.each do |level_up|
            classe = class_definition(level_up.class_key)
            base += classe&.mp_per_level || 0

            if (spell_attr = classe&.spellcasting&.dig("attribute"))
              attr_bonus += computed_attributes.dig(spell_attr, :modifier) || 0
            end
          end

          total = base + attr_bonus + sum_bonuses(other_bonuses)

          {
            base: base,
            attribute_bonus: attr_bonus,
            other_bonuses: other_bonuses,
            max: [total, 0].max
          }
        end

        def collect_pv_bonuses(context, computed_attributes)
          bonuses = []
          total_level = context.level_ups.size

          collect_all_power_keys(context).each do |power_key|
            poder = power_definition(power_key)
            next unless poder

            effects = poder.effects
            next unless effects.is_a?(Array)

            effects.each do |effect|
              next unless effect.is_a?(Hash)

              case effect["type"]
              when "PV_improvement"
                value = effect["value"]
                next unless value.is_a?(Integer)

                if effect["extra_details"] == "por_nivel_do_personagem"
                  bonuses << { label: poder.name, value: value * total_level }
                else
                  d = effect["duration"].to_s
                  next if d.present? && !d.start_with?("permanente")
                  bonuses << { label: poder.name, value: value }
                end
              when "add_PV_attr"
                attr_full = ATTR_MAP[effect["attr"]]
                next unless attr_full

                modifier = computed_attributes.dig(attr_full, :modifier) || 0
                bonuses << { label: poder.name, value: modifier } if modifier != 0
              end
            end
          end

          bonuses
        end

        def collect_pm_bonuses(context, computed_attributes)
          bonuses = []

          collect_all_power_keys(context).each do |power_key|
            poder = power_definition(power_key)
            next unless poder

            effects = poder.effects
            next unless effects.is_a?(Array)

            effects.each do |effect|
              next unless effect.is_a?(Hash)

              case effect["type"]
              when "PM_improvement", "pm_improvement", "PM_improvemente"
                value = effect["value"]
                next unless value.is_a?(Integer)

                d = (effect["duration"] || effect["duraction"]).to_s
                next if d.present? && !d.start_with?("permanente")
                next if effect["requirement"].present? || effect["requirements"].present?

                bonuses << { label: poder.name, value: value }
              when "add_attr_PM", "PM_bonus_attr"
                attr_full = ATTR_MAP[effect["attr"]]
                next unless attr_full

                modifier = computed_attributes.dig(attr_full, :modifier) || 0
                bonuses << { label: poder.name, value: modifier } if modifier != 0
              end
            end
          end

          bonuses
        end

        def compute_movement(context)
          race = race_definition(context.character_sheet.race_key)
          base = race&.movement || 9

          armor_penalty = calculate_armor_penalty(context.state)
          other_bonuses = []

          total = base - armor_penalty + sum_bonuses(other_bonuses)

          {
            base: base,
            armor_penalty: armor_penalty,
            other_bonuses: other_bonuses,
            total: [total, 3].max
          }
        end

        def calculate_armor_penalty(state)
          armor_key = state&.equipped_items&.dig("armor", "item_key")
          return 0 unless armor_key

          armor = armor_definition(armor_key)
          armor&.armor_penalty || 0
        end
      end
    end
  end
end
