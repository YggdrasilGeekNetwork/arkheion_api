# frozen_string_literal: true

module Tormenta20
  module Pipeline
    module Pipes
      class ComputeSpells < BasePipe
        def call(context)
          computed_attributes = context[:computed_attributes]

          known_spells = collect_known_spells(context)
          spell_slots = calculate_spell_slots(context)
          save_dc = calculate_spell_save_dc(context, computed_attributes)

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
                range: magia&.range,
                duration: magia&.duration,
                description: magia&.description,
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

          context.level_ups.each do |level_up|
            classe = class_definition(level_up.class_key)
            next unless classe&.conjurador?

            caster_level = count_caster_levels(context, level_up.class_key)

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

          {
            base: base,
            attribute_modifier: attr_mod,
            total: base + attr_mod
          }
        end

        def determine_spellcasting_attribute(context)
          context.level_ups.each do |level_up|
            classe = class_definition(level_up.class_key)
            attr = classe&.spellcasting&.dig("attribute")
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
