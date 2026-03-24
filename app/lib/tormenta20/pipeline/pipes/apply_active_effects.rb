# frozen_string_literal: true

module Tormenta20
  module Pipeline
    module Pipes
      class ApplyActiveEffects < BasePipe
        def call(context)
          state = context.state
          return context unless state&.active_effects.present?

          state.active_effects.each do |effect|
            apply_effect(context, effect)
          end

          context
        end

        private

        def apply_effect(context, effect)
          modifiers = effect["modifiers"] || {}

          modifiers.each do |target, value|
            case target
            when /^attribute_(.+)$/
              apply_attribute_modifier(context, ::Regexp.last_match(1), value)
            when /^skill_(.+)$/
              apply_skill_modifier(context, ::Regexp.last_match(1), value)
            when /^defense_(.+)$/
              apply_defense_modifier(context, ::Regexp.last_match(1), value)
            when "attack_melee"
              apply_attack_modifier(context, :melee_attack, value)
            when "attack_ranged"
              apply_attack_modifier(context, :ranged_attack, value)
            when "pv_max"
              apply_resource_modifier(context, :pv, :max, value)
            when "pm_max"
              apply_resource_modifier(context, :pm, :max, value)
            when "movement"
              apply_resource_modifier(context, :deslocamento, :total, value)
            end
          end
        end

        def apply_attribute_modifier(context, attr, value)
          computed = context[:computed_attributes]
          return unless computed[attr]

          computed[attr][:effect_bonus] ||= 0
          computed[attr][:effect_bonus] += value
          computed[attr][:total] += value
          computed[attr][:modifier] = modifier_for(computed[attr][:total])
        end

        def apply_skill_modifier(context, skill, value)
          computed = context[:computed_skills]
          return unless computed[skill]

          computed[skill][:effect_bonus] ||= 0
          computed[skill][:effect_bonus] += value
          computed[skill][:total] += value
        end

        def apply_defense_modifier(context, defense, value)
          computed = context[:computed_defenses]
          return unless computed[defense.to_sym]

          computed[defense.to_sym][:effect_bonus] ||= 0
          computed[defense.to_sym][:effect_bonus] += value
          computed[defense.to_sym][:total] += value
        end

        def apply_attack_modifier(context, attack_type, value)
          computed = context[:computed_combat]
          return unless computed[attack_type]

          computed[attack_type][:effect_bonus] ||= 0
          computed[attack_type][:effect_bonus] += value
          computed[attack_type][:total] += value
        end

        def apply_resource_modifier(context, resource, field, value)
          computed = context[:computed_resources]
          return unless computed[resource]

          computed[resource]["effect_bonus_#{field}".to_sym] ||= 0
          computed[resource]["effect_bonus_#{field}".to_sym] += value
          computed[resource][field] += value
        end
      end
    end
  end
end
