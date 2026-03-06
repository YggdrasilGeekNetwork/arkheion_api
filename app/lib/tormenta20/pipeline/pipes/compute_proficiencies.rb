# frozen_string_literal: true

module Tormenta20
  module Pipeline
    module Pipes
      class ComputeProficiencies < BasePipe
        def call(context)
          proficiencies = {
            weapons: Set.new,
            armors: Set.new,
            shields: Set.new,
            tools: Set.new,
            exotic_weapons: Set.new
          }

          add_class_proficiencies(proficiencies, context)
          add_origin_proficiencies(proficiencies, context)

          context[:computed_proficiencies] = {
            weapons: proficiencies[:weapons].to_a,
            armors: proficiencies[:armors].to_a,
            shields: proficiencies[:shields].to_a,
            tools: proficiencies[:tools].to_a,
            exotic_weapons: proficiencies[:exotic_weapons].to_a
          }

          context
        end

        private

        def add_class_proficiencies(proficiencies, context)
          context.level_ups.each do |level_up|
            next unless level_up.first_level_in_class?

            classe = class_definition(level_up.class_key)
            next unless classe

            proficiencies[:weapons].merge(classe.weapon_proficiencies)
            proficiencies[:armors].merge(classe.armor_proficiencies)
            proficiencies[:shields] << "escudos" if classe.shield_proficiency?
          end
        end

        def add_origin_proficiencies(proficiencies, context)
          chosen = context.character_sheet.origin_choices["chosen_proficiencies"] || []
          proficiencies[:tools].merge(chosen)
        end
      end
    end
  end
end
