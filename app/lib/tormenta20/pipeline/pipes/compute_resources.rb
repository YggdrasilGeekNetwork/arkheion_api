# frozen_string_literal: true

module Tormenta20
  module Pipeline
    module Pipes
      class ComputeResources < BasePipe
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
          other_bonuses = []

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
          other_bonuses = []

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
