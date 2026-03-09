# frozen_string_literal: true

module Queries
  module Tormenta20
    class ClassPowersForLevelQuery < GraphQL::Schema::Resolver
      argument :class_key,    String,  required: true
      argument :level,        Integer, required: true
      argument :character_id, ID,      required: false

      type Types::Tormenta20::ClassLevelAbilitiesType, null: true

      def resolve(class_key:, level:, character_id: nil)
        classe = ::Tormenta20::Models::Classe.find_by(id: class_key)
        return nil unless classe

        level_entry   = classe.progression&.find { |p| p["level"] == level }
        level_keys    = level_entry&.dig("abilities") || []

        power_choices     = level_keys.count { |k| k.start_with?("poder_de_") }
        fixed_ability_keys = level_keys.reject { |k| k.start_with?("poder_de_") }

        # Resolve fixed ability display names
        fixed_names = fixed_ability_keys.map do |key|
          poder = ::Tormenta20::Models::Poder.find_by(id: key)
          poder&.name || key.humanize
        end

        # Find already-chosen class powers for this character
        already_chosen = []
        if character_id
          sheet = ::Tormenta20::CharacterSheet.find_by(id: character_id)
          if sheet
            sheet.level_ups.where(class_key: class_key).each do |lu|
              already_chosen.concat(lu.abilities_chosen["class_abilities"] || [])
            end
          end
        end

        # Build selectable powers list
        powers = (classe.powers || [])
          .reject { |k| already_chosen.include?(k) }
          .filter_map { |k| ::Tormenta20::Models::Poder.find_by(id: k) }
          .map { |p| format_power(p, class_key) }

        {
          power_choices: power_choices,
          fixed_abilities: fixed_names,
          selectable_powers: powers
        }
      end

      private

      def format_power(poder, source)
        effects = poder.effects
        is_active = effects.is_a?(Hash) && (effects["type"] == "active" || effects.key?("cost"))

        cost_pm = nil
        if is_active && effects.is_a?(Hash)
          cost_str = effects["cost"].to_s
          cost_pm  = cost_str.match(/(\d+)\s*PM/)&.captures&.first&.to_i
        end

        {
          id: poder.id,
          name: poder.name,
          description: poder.description || "",
          type: is_active ? "active" : "passive",
          cost: cost_pm ? { pm: cost_pm, pv: nil } : nil,
          source: source
        }
      end
    end
  end
end
