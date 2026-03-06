# frozen_string_literal: true

module Tormenta20
  module Pipeline
    module Pipes
      class ComputeSkills < BasePipe
        SKILLS = {
          'acrobacia' => 'destreza',
          'adestramento' => 'carisma',
          'atletismo' => 'forca',
          'atuacao' => 'carisma',
          'cavalgar' => 'destreza',
          'conhecimento' => 'inteligencia',
          'cura' => 'sabedoria',
          'diplomacia' => 'carisma',
          'enganacao' => 'carisma',
          'fortitude' => 'constituicao',
          'furtividade' => 'destreza',
          'guerra' => 'inteligencia',
          'iniciativa' => 'destreza',
          'intimidacao' => 'carisma',
          'intuicao' => 'sabedoria',
          'investigacao' => 'inteligencia',
          'jogatina' => 'carisma',
          'ladinagem' => 'destreza',
          'luta' => 'forca',
          'misticismo' => 'inteligencia',
          'nobreza' => 'inteligencia',
          'oficio' => 'inteligencia',
          'percepcao' => 'sabedoria',
          'pilotagem' => 'destreza',
          'pontaria' => 'destreza',
          'reflexos' => 'destreza',
          'religiao' => 'sabedoria',
          'sobrevivencia' => 'sabedoria',
          'vontade' => 'sabedoria'
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
          origin_skills = context.character_sheet.origin_choices['chosen_skills'] || []
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
          race_skills = context.character_sheet.race_choices['chosen_skills'] || []
          bonuses << { source: 'race', value: 2 } if race_skills.include?(skill)

          # Would collect from powers, items, effects, etc.

          bonuses
        end
      end
    end
  end
end
