# frozen_string_literal: true

module Tormenta20
  module Pipeline
    module Pipes
      class ComputeSkills < BasePipe
        ATTR_MAP = {
          "for" => "forca", "des" => "destreza", "con" => "constituicao",
          "int" => "inteligencia", "sab" => "sabedoria", "car" => "carisma"
        }.freeze

        SKILLS = {
          "acrobacia" => "destreza",
          "adestramento" => "carisma",
          "atletismo" => "forca",
          "atuacao" => "carisma",
          "cavalgar" => "destreza",
          "conhecimento" => "inteligencia",
          "cura" => "sabedoria",
          "diplomacia" => "carisma",
          "enganacao" => "carisma",
          "fortitude" => "constituicao",
          "furtividade" => "destreza",
          "guerra" => "inteligencia",
          "iniciativa" => "destreza",
          "intimidacao" => "carisma",
          "intuicao" => "sabedoria",
          "investigacao" => "inteligencia",
          "jogatina" => "carisma",
          "ladinagem" => "destreza",
          "luta" => "forca",
          "misticismo" => "inteligencia",
          "nobreza" => "inteligencia",
          "oficio" => "inteligencia",
          "percepcao" => "sabedoria",
          "pilotagem" => "destreza",
          "pontaria" => "destreza",
          "reflexos" => "destreza",
          "religiao" => "sabedoria",
          "sobrevivencia" => "sabedoria",
          "vontade" => "sabedoria"
        }.freeze

        def call(context)
          computed_attributes = context[:computed_attributes]
          computed_skills = {}

          SKILLS.each do |skill, attribute|
            ranks = calculate_ranks(context, skill)
            attr_modifier = computed_attributes.dig(attribute, :modifier) || 0
            trained = ranks > 0
            other_bonuses = collect_skill_bonuses(context, skill)

            # Training bonus (+2 in T20)
            training_bonus = trained ? 2 : 0

            total = ranks + attr_modifier + training_bonus + sum_bonuses(other_bonuses)

            computed_skills[skill] = {
              ranks: ranks,
              level_bonus: ranks,
              attribute: attribute,
              attribute_modifier: attr_modifier,
              trained: trained,
              training_bonus: training_bonus,
              other_bonuses: other_bonuses,
              total: total
            }
          end

          context[:computed_skills] = computed_skills
          context
        end

        private

        def calculate_ranks(context, skill)
          total = 0

          # From origin
          origin_skills = context.character_sheet.origin_choices["chosen_skills"] || []
          total += 2 if origin_skills.include?(skill)

          # From level ups
          context.level_ups.each do |level_up|
            skill_points = level_up.skill_points || {}
            total += skill_points[skill] || 0
          end

          total
        end

        def collect_skill_bonuses(context, skill)
          bonuses = []

          # Race bonuses to skills
          race_skills = context.character_sheet.race_choices["chosen_skills"] || []
          bonuses << { label: "Raça", value: 2 } if race_skills.include?(skill)

          # Power bonuses to skills
          computed_attributes = context[:computed_attributes]

          collect_all_power_keys(context).each do |power_key|
            poder = power_definition(power_key)
            next unless poder

            effects = poder.effects
            next unless effects.is_a?(Array)

            effects.each do |effect|
              next unless effect.is_a?(Hash)

              case effect["type"]
              when "skill_improvement", "expertise_improvement"
                target = effect["skill"] || effect["expertise"]
                next unless target == skill

                value = effect["value"]
                next unless value.is_a?(Integer)

                d = effect["duration"].to_s
                next if d.present? && !d.start_with?("permanente")
                next if effect["requirement"].present? || effect["requirements"].present?

                bonuses << { label: poder.name, value: value }
              when "add_attr_bonus_to_skill"
                target = effect["skill"]
                next unless target == skill

                attr_full = ATTR_MAP[effect["attr"]]
                next unless attr_full

                modifier = computed_attributes&.dig(attr_full, :modifier) || 0
                bonuses << { label: poder.name, value: modifier } if modifier != 0
              end
            end
          end

          bonuses
        end
      end
    end
  end
end
