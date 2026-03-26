# frozen_string_literal: true

module Tormenta20
  module Pipeline
    module Pipes
      class ApplyConditions < BasePipe
        CONDITION_EFFECTS = {
          "abalado" => { skills: { all: -2 } },
          "agarrado" => { defense: -4, movement: 0 },
          "apavorado" => { skills: { all: -2 }, attack: -2, flee: true },
          "atordoado" => { defense: -2, no_actions: true },
          "caido" => { defense_melee: -4, defense_ranged: 4, attack_melee: -4 },
          "cego" => { defense: -2, attack: -4, movement_half: true },
          "confuso" => { random_actions: true },
          "desprevenido" => { no_dex_to_defense: true },
          "em_chamas" => { damage_per_round: "1d6" },
          "enjoado" => { attack: -2, skills: { all: -2 } },
          "enredado" => { defense: -2, attack: -2, movement_half: true },
          "exausto" => { movement_half: true, attributes: { forca: -6, destreza: -6 } },
          "fascinado" => { no_actions: true, perception: -4 },
          "fatigado" => { attributes: { forca: -2, destreza: -2 }, no_run: true },
          "fraco" => { attributes: { forca: -6 } },
          "frustrado" => { pm_cost: 1 },
          "imobilizado" => { movement: 0, defense: -4 },
          "inconsciente" => { helpless: true },
          "lento" => { movement_half: true, defense: -1, attack: -1 },
          "ofuscado" => { attack: -1, perception: -1 },
          "paralisado" => { helpless: true },
          "pasmo" => { no_actions_round: true },
          "petrificado" => { helpless: true, dr: 8 },
          "sangrando" => { damage_per_round: 1 },
          "surdo" => { initiative: -4, perception_hearing: :auto_fail },
          "surpreendido" => { no_dex_to_defense: true, no_actions_round: true },
          "vulneravel" => { defense: -5 }
        }.freeze

        def call(context)
          state = context.state
          return context unless state&.active_conditions.present?

          active_conditions = state.active_conditions

          context[:active_condition_effects] = active_conditions.map do |condition|
            condition_key = condition["condition_key"]
            {
              condition_key: condition_key,
              effects: CONDITION_EFFECTS[condition_key] || {},
              stacks: condition["stacks"] || 1,
              source: condition["source"]
            }
          end

          # Apply condition effects to computed values
          apply_condition_effects(context)

          context
        end

        private

        def apply_condition_effects(context)
          effects = context[:active_condition_effects] || []

          effects.each do |effect_data|
            effects_hash = effect_data[:effects]
            stacks = effect_data[:stacks]

            apply_attribute_penalties(context, effects_hash[:attributes], stacks)
            apply_defense_penalty(context, effects_hash[:defense], stacks)
            apply_attack_penalty(context, effects_hash[:attack], %i[melee_attack ranged_attack], stacks)
            apply_attack_penalty(context, effects_hash[:attack_melee], %i[melee_attack], stacks)
            apply_attack_penalty(context, effects_hash[:attack_ranged], %i[ranged_attack], stacks)
            apply_skill_penalties(context, effects_hash[:skills], stacks)
            apply_movement_penalty(context, effects_hash)
          end
        end

        def apply_attribute_penalties(context, penalties, stacks)
          return unless penalties

          computed = context[:computed_attributes]
          penalties.each do |attr, penalty|
            next unless computed[attr.to_s]

            computed[attr.to_s][:condition_penalty] ||= 0
            computed[attr.to_s][:condition_penalty] += penalty * stacks
            computed[attr.to_s][:total] += penalty * stacks
            computed[attr.to_s][:modifier] = computed[attr.to_s][:total]
          end
        end

        def apply_defense_penalty(context, penalty, stacks)
          return unless penalty

          computed = context[:computed_defenses]
          return unless computed[:defesa]

          computed[:defesa][:condition_penalty] ||= 0
          computed[:defesa][:condition_penalty] += penalty * stacks
          computed[:defesa][:total] += penalty * stacks
        end

        def apply_attack_penalty(context, penalty, attack_types, stacks)
          return unless penalty

          computed = context[:computed_combat]
          return unless computed

          attack_types.each do |attack_type|
            next unless computed[attack_type]

            computed[attack_type][:condition_penalty] ||= 0
            computed[attack_type][:condition_penalty] += penalty * stacks
            computed[attack_type][:total] += penalty * stacks
          end
        end

        def apply_skill_penalties(context, penalties, stacks)
          return unless penalties

          computed = context[:computed_skills]
          return unless computed

          if penalties[:all]
            computed.each_value do |skill|
              skill[:condition_penalty] ||= 0
              skill[:condition_penalty] += penalties[:all] * stacks
              skill[:total] += penalties[:all] * stacks
            end
          end
        end

        def apply_movement_penalty(context, effects)
          computed = context[:computed_resources]
          return unless computed&.dig(:deslocamento)

          if effects[:movement] == 0
            computed[:deslocamento][:total] = 0
          elsif effects[:movement_half]
            computed[:deslocamento][:total] = (computed[:deslocamento][:total] / 2.0).floor
          end
        end
      end
    end
  end
end
