# frozen_string_literal: true

module Tormenta20
  module Pipeline
    module Pipes
      class ComputeBaseAttributes < BasePipe
        def call(context)
          sheet = context.character_sheet
          base_attributes = sheet.sheet_attributes || {}

          computed = {}

          %w[forca destreza constituicao inteligencia sabedoria carisma].each do |attr|
            base = base_attributes[attr] || 0
            bonuses = collect_bonuses(context, attr)
            total = base + sum_bonuses(bonuses)

            computed[attr] = {
              base: base,
              bonuses: bonuses,
              total: total,
              modifier: total
            }
          end

          context[:computed_attributes] = computed
          context
        end

        private

        def collect_bonuses(context, attr)
          bonuses = []

          # Race bonuses from gem
          race = race_definition(context.character_sheet.race_key)
          race_bonus = race&.attribute_bonus_for(attr)
          bonuses << { source: "race", value: race_bonus } if race_bonus && race_bonus != 0

          # Chosen attribute bonuses (e.g. Qareen selecting +1 to a second attribute)
          chosen_bonus = context.character_sheet.race_choices.dig("chosen_attribute_bonuses", attr)
          bonuses << { source: "race_choice", value: chosen_bonus } if chosen_bonus && chosen_bonus != 0

          # Level-based attribute increases (every 4 levels in T20)
          context.level_ups.each do |level_up|
            if level_up.metadata&.dig("attribute_increase") == attr
              bonuses << { source: "level_#{level_up.level}", value: 1 }
            end
          end

          bonuses
        end
      end
    end
  end
end
