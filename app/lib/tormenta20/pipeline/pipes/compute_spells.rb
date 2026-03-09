# frozen_string_literal: true

module Tormenta20
  module Pipeline
    module Pipes
      class ComputeSpells < BasePipe
        # T20 spellcasting classes and their governing attribute.
        # The gem's `spellcasting` column is unpopulated, so we define the map here.
        SPELLCASTING_ATTRIBUTES = {
          "arcanista" => "inteligencia",
          "clerigo"   => "sabedoria",
          "druida"    => "sabedoria",
          "bardo"     => "carisma",
          "cacador"   => "sabedoria"
        }.freeze

        def call(context)
          computed_attributes = context[:computed_attributes]

          known_spells = collect_known_spells(context)
          spell_slots  = calculate_spell_slots(context)
          save_dc      = calculate_spell_save_dc(context, computed_attributes)

          context[:computed_spells] = {
            known_spells: known_spells,
            spell_slots: spell_slots,
            save_dc: save_dc,
            spellcasting_attribute: determine_spellcasting_attribute(context)
          }

          context
        end

        private

        def collect_known_spells(context)
          spells = []

          context.level_ups.each do |level_up|
            (level_up.spells_chosen["known_spells"] || []).each do |spell_data|
              spell_key = spell_data["spell_key"] || spell_data
              magia = spell_definition(spell_key)

              spells << {
                spell_key: spell_key,
                name: magia&.name || spell_key.humanize,
                circle: magia&.circle || spell_data["circle"],
                school: magia&.school || spell_data["school"],
                type: magia&.type,
                execution: magia&.execution,
                execution_details: magia&.execution_details,
                range: magia&.range,
                duration: magia&.duration,
                duration_details: magia&.duration_details,
                description: magia&.description,
                counterspell: magia&.counterspell,
                area_effect: magia&.area_effect,
                area_effect_details: magia&.area_effect_details,
                target_type: magia&.target_type,
                target_amount: magia&.target_amount,
                target_up_to: magia&.target_up_to,
                resistence_skill: magia&.resistence_skill,
                resistence_effect: magia&.resistence_effect,
                extra_costs_material_component: magia&.extra_costs_material_component,
                extra_costs_material_cost: magia&.extra_costs_material_cost,
                extra_costs_pm_debuff: magia&.extra_costs_pm_debuff,
                extra_costs_pm_sacrifice: magia&.extra_costs_pm_sacrifice,
                effects: magia&.effects || [],
                enhancements: magia&.enhancements || [],
                learned_at_level: level_up.level,
                class_key: level_up.class_key
              }
            end
          end

          spells
        end

        def calculate_spell_slots(context)
          slots = { 1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0 }

          context.level_ups.group_by(&:class_key).each do |class_key, ups|
            next unless SPELLCASTING_ATTRIBUTES.key?(class_key)

            caster_level = ups.count
            slots[1] += 1 if caster_level >= 1
            slots[2] += 1 if caster_level >= 3
            slots[3] += 1 if caster_level >= 5
            slots[4] += 1 if caster_level >= 7
            slots[5] += 1 if caster_level >= 9
          end

          slots
        end

        def calculate_spell_save_dc(context, computed_attributes)
          spell_attr = determine_spellcasting_attribute(context)
          return nil unless spell_attr

          base = 10
          attr_mod = computed_attributes.dig(spell_attr, :modifier) || 0
          permanent = collect_dc_bonuses(context, conditional: false)
          conditional = collect_dc_bonuses(context, conditional: true)
          bonus_total = permanent.sum { |b| b[:value] }

          {
            base: base,
            attribute_modifier: attr_mod,
            other_bonuses: permanent,
            conditional_bonuses: conditional,
            total: base + attr_mod + bonus_total
          }
        end

        def collect_dc_bonuses(context, conditional:)
          bonuses = []
          collect_all_power_keys(context).each do |power_key|
            definition = power_definition(power_key)
            next unless definition&.effects.is_a?(Array)

            definition.effects.each do |effect|
              next unless effect["type"] == "CD_improvement"

              is_conditional = effect["requirements"].present?
              next if is_conditional != conditional

              value = effect["value"]
              next unless value.is_a?(Integer)

              entry = { label: definition.name, value: value }
              entry[:condition] = effect["requirements"] if conditional
              bonuses << entry
            end
          end
          bonuses
        end

        def determine_spellcasting_attribute(context)
          context.level_ups.each do |level_up|
            attr = SPELLCASTING_ATTRIBUTES[level_up.class_key]
            return attr if attr
          end
          nil
        end

        def count_caster_levels(context, class_key)
          context.level_ups.count { |lu| lu.class_key == class_key }
        end
      end
    end
  end
end
