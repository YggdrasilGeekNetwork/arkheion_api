# frozen_string_literal: true

module Tormenta20
  module Pipeline
    module Pipes
      class ApplyEncumbrance < BasePipe
        DEFENSE_PENALTY  = -5
        MOVEMENT_PENALTY = -3

        def call(context)
          state = context.state
          return context unless state

          for_mod   = context[:computed_attributes]&.dig("forca", :modifier) || 0
          max_carry = 10 + (for_mod >= 0 ? for_mod * 2 : for_mod)

          total_spaces = compute_total_spaces(state)
          return context unless total_spaces > max_carry

          apply_defense_penalty(context)
          apply_movement_penalty(context)

          context
        end

        private

        def compute_total_spaces(state)
          equipped_spaces(state) + backpack_spaces(state) + currency_spaces(state)
        end

        def equipped_spaces(state)
          return 0 unless state.equipped_items.present?

          state.equipped_items.sum do |_slot, slot_data|
            next 0 unless slot_data.is_a?(Hash)
            item_key = slot_data["item_key"]
            next 0 unless item_key
            item_weight(item_key)
          end
        end

        def backpack_spaces(state)
          return 0 unless state.inventory.present?

          state.inventory.sum do |entry|
            next 0 unless entry.is_a?(Hash)
            item_key = entry["item_key"]
            qty = (entry["quantity"] || 1).to_i
            next 0 unless item_key
            item_weight(item_key) * qty
          end
        end

        def currency_spaces(state)
          return 0 unless state.currency.present?

          to = state.currency["to"].to_i
          tp = state.currency["tp"].to_i
          tc = state.currency["tc"].to_i
          (to / 1000) + (tp / 1000) + (tc / 1000)
        end

        def item_weight(item_key)
          record = weapon_definition(item_key) ||
                   armor_definition(item_key)  ||
                   shield_definition(item_key) ||
                   item_definition(item_key)
          record&.weight.to_f.positive? ? record.weight.to_f : 1.0
        end

        def apply_defense_penalty(context)
          defesa = context[:computed_defenses]&.dig(:defesa)
          return unless defesa

          defesa[:encumbrance_penalty] = DEFENSE_PENALTY
          defesa[:total] += DEFENSE_PENALTY
        end

        def apply_movement_penalty(context)
          deslocamento = context[:computed_resources]&.dig(:deslocamento)
          return unless deslocamento

          deslocamento[:encumbrance_penalty] = MOVEMENT_PENALTY
          deslocamento[:total] = [deslocamento[:total] + MOVEMENT_PENALTY, 0].max
        end
      end
    end
  end
end
