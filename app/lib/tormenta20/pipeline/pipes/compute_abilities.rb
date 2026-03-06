# frozen_string_literal: true

module Tormenta20
  module Pipeline
    module Pipes
      class ComputeAbilities < BasePipe
        def call(context)
          abilities = []

          abilities.concat(collect_race_abilities(context))
          abilities.concat(collect_origin_abilities(context))
          abilities.concat(collect_class_abilities(context))
          abilities.concat(collect_powers(context))

          context[:computed_abilities] = abilities
          context
        end

        private

        def collect_race_abilities(context)
          race_key = context.character_sheet.race_key
          race = race_definition(race_key)
          abilities = []

          (race&.racial_abilities || []).each do |ability_key|
            poder = power_definition(ability_key)
            abilities << build_ability(ability_key, poder, "race:#{race_key}", :racial)
          end

          (context.character_sheet.race_choices["chosen_abilities"] || []).each do |ability_key|
            poder = power_definition(ability_key)
            abilities << build_ability(ability_key, poder, "race:#{race_key}:choice", :racial_choice)
          end

          abilities
        end

        def collect_origin_abilities(context)
          origin_key = context.character_sheet.origin_key
          abilities = []

          (context.character_sheet.origin_choices["chosen_powers"] || []).each do |power_key|
            poder = power_definition(power_key)
            abilities << build_ability(power_key, poder, "origin:#{origin_key}", :origin_power)
          end

          abilities
        end

        def collect_class_abilities(context)
          abilities = []

          context.level_ups.each do |level_up|
            class_key = level_up.class_key
            source_prefix = "class:#{class_key}:#{level_up.level}"

            (level_up.abilities_chosen["class_abilities"] || []).each do |ability_key|
              poder = power_definition(ability_key)
              abilities << build_ability(ability_key, poder, source_prefix, :class_ability)
            end

            (level_up.abilities_chosen["bonus_abilities"] || []).each do |ability_key|
              poder = power_definition(ability_key)
              abilities << build_ability(ability_key, poder, "#{source_prefix}:bonus", :bonus_ability)
            end
          end

          abilities
        end

        def collect_powers(context)
          powers = []

          context.level_ups.each do |level_up|
            level_up.powers_chosen.each do |category, power_keys|
              (power_keys || []).each do |power_key|
                poder = power_definition(power_key)
                powers << build_ability(power_key, poder, "power:#{category}:#{level_up.level}", category.to_sym)
              end
            end
          end

          powers
        end

        def build_ability(key, poder, source, type)
          {
            ability_key: key,
            name: poder&.name || key.humanize,
            description: poder&.description,
            effects: poder&.effects || {},
            source: source,
            type: type
          }
        end
      end
    end
  end
end
