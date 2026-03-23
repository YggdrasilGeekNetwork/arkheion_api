# frozen_string_literal: true

module Tormenta20
  module Pipeline
    module Pipes
      class ComputeDefenses < BasePipe
        SAVE_SKILLS = %w[fortitude reflexos vontade].freeze

        def call(context)
          computed_attributes = context[:computed_attributes]
          state = context.state

          context[:computed_defenses] = {
            defesa: compute_defense(context, computed_attributes, state),
            fortitude: compute_save(context, computed_attributes, "fortitude", "constituicao"),
            reflexos: compute_save(context, computed_attributes, "reflexos", "destreza"),
            vontade: compute_save(context, computed_attributes, "vontade", "sabedoria")
          }

          context
        end

        private

        def compute_defense(context, computed_attributes, state)
          base = 10
          dex_mod = computed_attributes.dig("destreza", :modifier) || 0

          armor_bonus = calculate_armor_bonus(state)
          shield_bonus = calculate_shield_bonus(state)
          other_bonuses = collect_defense_bonuses(context)

          max_dex = armor_max_dex(state)
          effective_dex = max_dex ? [dex_mod, max_dex].min : dex_mod

          total = base + effective_dex + armor_bonus + shield_bonus + sum_bonuses(other_bonuses)

          {
            base: base,
            dexterity_bonus: effective_dex,
            armor_bonus: armor_bonus,
            shield_bonus: shield_bonus,
            other_bonuses: other_bonuses,
            total: total
          }
        end

        def compute_save(context, computed_attributes, save_type, attribute)
          base = 0
          attr_mod = computed_attributes.dig(attribute, :modifier) || 0
          other_bonuses = collect_save_bonuses(context, save_type)

          total = base + attr_mod + sum_bonuses(other_bonuses)

          {
            base: base,
            attribute: attribute,
            attribute_bonus: attr_mod,
            other_bonuses: other_bonuses,
            total: total
          }
        end

        def collect_defense_bonuses(context)
          bonuses = []

          collect_all_power_keys(context).each do |power_key|
            poder = power_definition(power_key)
            next unless poder

            effects = poder.effects
            next unless effects.is_a?(Array)

            effects.each do |effect|
              next unless effect.is_a?(Hash)
              next unless %w[defense_improvement defense_improvment].include?(effect["type"])

              value = effect["value"]
              next unless value.is_a?(Integer)

              d = effect["duration"].to_s
              next if d.present? && !d.start_with?("permanente")
              next if effect["requirement"].present? || effect["requirements"].present?

              bonuses << { label: poder.name, value: value }
            end
          end

          bonuses
        end

        def collect_save_bonuses(context, save_type)
          bonuses = []

          collect_all_power_keys(context).each do |power_key|
            poder = power_definition(power_key)
            next unless poder

            effects = poder.effects
            next unless effects.is_a?(Array)

            effects.each do |effect|
              next unless effect.is_a?(Hash)
              next unless %w[skill_improvement expertise_improvement].include?(effect["type"])

              skill = effect["skill"] || effect["expertise"]
              next unless skill == save_type

              value = effect["value"]
              next unless value.is_a?(Integer)

              d = effect["duration"].to_s
              next if d.present? && !d.start_with?("permanente")
              next if effect["requirement"].present? || effect["requirements"].present?

              bonuses << { label: poder.name, value: value }
            end
          end

          bonuses
        end

        def calculate_armor_bonus(state)
          armor_key = state&.equipped_items&.dig("armor", "item_key")
          return 0 unless armor_key

          armor_definition(armor_key)&.defense_bonus || 0
        end

        def calculate_shield_bonus(state)
          shield_key = state&.equipped_items&.dig("shield", "item_key")
          return 0 unless shield_key

          shield_definition(shield_key)&.defense_bonus || 0
        end

        def armor_max_dex(state)
          armor_key = state&.equipped_items&.dig("armor", "item_key")
          return nil unless armor_key

          props = armor_definition(armor_key)&.properties
          props.is_a?(Hash) ? props["max_dex"] : nil
        end
      end
    end
  end
end
