# frozen_string_literal: true

module Tormenta20
  module Pipeline
    module Pipes
      class ComputeDefenses < BasePipe
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
          other_bonuses = []

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
          other_bonuses = []

          total = base + attr_mod + sum_bonuses(other_bonuses)

          {
            base: base,
            attribute: attribute,
            attribute_bonus: attr_mod,
            other_bonuses: other_bonuses,
            total: total
          }
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

          armor_definition(armor_key)&.properties&.dig("max_dex")
        end
      end
    end
  end
end
