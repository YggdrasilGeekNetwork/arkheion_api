# frozen_string_literal: true

module Tormenta20
  # Builds the wizard choice definition for a given origin.
  # Every origin (except those with no benefits) allows the player to choose one of:
  #   - 2 skills
  #   - 2 powers
  #   - 1 skill + 1 power
  # from the origin's benefit list.
  #
  # Returns an Array with a single "origem-mode" choice hash, or [] if the origin
  # has no choosable benefits (e.g. Amnésico).
  class OriginChoicesBuilder
    class << self
      def build(origem)
        skills = origem.benefits&.dig("skills") || []
        powers = resolve_powers(origem.benefits&.dig("powers") || [])

        return [] if skills.empty? && powers.empty?

        options = []
        options << { id: "two-skills",     name: "2 perícias",               description: "Escolha 2 perícias da lista da origem" }       if skills.length >= 2
        options << { id: "two-powers",     name: "2 poderes",                description: "Escolha 2 poderes da lista da origem" }        if powers.length >= 2
        options << { id: "skill-and-power", name: "1 perícia e 1 poder",     description: "Escolha 1 perícia e 1 poder da lista da origem" } if skills.any? && powers.any?

        return [] if options.length < 2

        [
          {
            id: "origem-mode",
            title: "Benefícios da Origem",
            description: "Escolha como receber os benefícios da sua origem",
            type: "single",
            minSelections: 1,
            maxSelections: 1,
            targetStep: "origin",
            effectType: "origem-mode",
            options: options,
            # Embed available skills and powers so the frontend can spawn sub-choices
            availableSkills: skills.map { |s| { id: s, name: s } },
            availablePowers: powers
          }
        ]
      end

      private

      def resolve_powers(power_names)
        power_names.filter_map do |name|
          p = ::Tormenta20::Models::Poder.find_by(name: name)
          p ? {
            id: p.id,
            name: p.name,
            description: p.description&.first(120),
            prerequisites: p.prerequisites.presence || []
          } : nil
        end
      end
    end
  end
end
