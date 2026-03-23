# frozen_string_literal: true

module Tormenta20
  # Builds the wizard choice definitions for a given race.
  # Gem data captures fixed attribute bonuses and ability pools, but several
  # T20 races have nuanced rules (e.g. Humano's Versátil, Lefou's Deformidade)
  # that aren't encoded in the gem. Those are hardcoded here so that the
  # frontend never needs to know race-specific game rules.
  #
  # Returns an Array of hashes matching the ChoiceDefinition shape consumed
  # by the frontend wizard:
  #   { id, title, description, type, minSelections, maxSelections,
  #     targetStep, effectType, effectValue, options: [{id, name, description}] }
  class RaceChoicesBuilder
    ATTR_OPTIONS = [
      { id: "FOR", name: "Força" },
      { id: "DES", name: "Destreza" },
      { id: "CON", name: "Constituição" },
      { id: "INT", name: "Inteligência" },
      { id: "SAB", name: "Sabedoria" },
      { id: "CAR", name: "Carisma" },
    ].freeze

    ATTR_OPTIONS_NO_CAR = ATTR_OPTIONS.reject { |o| o[:id] == "CAR" }.freeze
    ATTR_OPTIONS_NO_CON = ATTR_OPTIONS.reject { |o| o[:id] == "CON" }.freeze

    # Damage types available for element-based choices (Golem, Qareen)
    ELEMENT_OPTIONS = [
      { id: "acido",        name: "Ácido" },
      { id: "eletricidade", name: "Eletricidade" },
      { id: "fogo",         name: "Fogo" },
      { id: "frio",         name: "Frio" },
      { id: "luz",   name: "Luz" },
      { id: "trevas", name: "Trevas" }
    ].freeze

    class << self
      def build(raca)
        case raca.id
        when "humano"        then humano_choices
        when "lefou"         then lefou_choices
        when "osteon"        then osteon_choices
        when "sereia_tritao" then sereia_tritao_choices
        when "silfide"       then silfide_choices
        when "kliren"        then kliren_choices
        when "golem"         then golem_choices
        when "qareen"        then qareen_choices
        else []
        end
      end

      private

      # ── Sereia/Tritão ────────────────────────────────────────────────────────

      def sereia_tritao_choices
        [
          {
            id: "attr-bonus",
            title: "Bônus de Atributo",
            description: "Escolha 3 atributos diferentes para receber +1 em cada um",
            type: "multiple",
            minSelections: 3,
            maxSelections: 3,
            targetStep: "race",
            effectType: "attribute-bonus",
            options: ATTR_OPTIONS
          },
          {
            id: "cancao-dos-mares",
            title: "Canção dos Mares",
            description: "Escolha 2 magias para aprender (atributo-chave: Carisma). Se aprender novamente uma delas, seu custo diminui em –1 PM",
            type: "multiple",
            minSelections: 2,
            maxSelections: 2,
            targetStep: "race",
            effectType: "spell-grant",
            options: [
              { id: "amedrontar", name: "Amedrontar" },
              { id: "comando",    name: "Comando" },
              { id: "despedacar", name: "Despedaçar" },
              { id: "enfeiticar", name: "Enfeitiçar" },
              { id: "hipnotismo", name: "Hipnotismo" },
              { id: "sono",       name: "Sono" }
            ]
          }
        ]
      end

      # ── Sílfide ──────────────────────────────────────────────────────────────

      def silfide_choices
        [
          {
            id: "magia-das-fadas",
            title: "Magia das Fadas",
            description: "Escolha 2 magias para aprender (atributo-chave: Carisma). Se aprender novamente uma delas, seu custo diminui em –1 PM",
            type: "multiple",
            minSelections: 2,
            maxSelections: 2,
            targetStep: "race",
            effectType: "spell-grant",
            options: [
              { id: "criar_ilusao", name: "Criar Ilusão" },
              { id: "enfeiticar",   name: "Enfeitiçar" },
              { id: "luz",          name: "Luz" },
              { id: "sono",         name: "Sono" }
            ]
          }
        ]
      end

      # ── Kliren ───────────────────────────────────────────────────────────────

      def kliren_choices
        [
          # +2 em Ofício é bônus fixo (Vanguardista), aplicado server-side.
          # options: [] sinaliza ao frontend para injetar loaderData.skills.
          {
            id: "skill-training",
            title: "Perícia Treinada",
            description: "Escolha 1 perícia para se tornar treinado (Híbrido)",
            type: "multiple",
            minSelections: 1,
            maxSelections: 1,
            targetStep: "race",
            effectType: "skill-training",
            options: []
          }
        ]
      end

      # ── Golem ────────────────────────────────────────────────────────────────

      def golem_choices
        [
          {
            id: "fonte-elemental",
            title: "Fonte Elemental",
            description: "Escolha 1 tipo de dano para ser imune e ser curado por (metade do dano recebido)",
            type: "multiple",
            minSelections: 1,
            maxSelections: 1,
            targetStep: "race",
            effectType: "element-choice",
            options: ELEMENT_OPTIONS
          },
          {
            id: "proposito-de-criacao",
            title: "Propósito de Criação",
            description: "Você não possui origem. Em compensação, escolha 1 poder geral",
            type: "multiple",
            minSelections: 1,
            maxSelections: 1,
            targetStep: "abilities",
            effectType: "spell-grant",
            options: general_power_options
          }
        ]
      end

      # ── Qareen ───────────────────────────────────────────────────────────────

      def qareen_choices
        [
          {
            id: "resistencia-elemental",
            title: "Resistência Elemental",
            description: "Escolha 1 tipo de dano para receber redução de dano 10",
            type: "multiple",
            minSelections: 1,
            maxSelections: 1,
            targetStep: "race",
            effectType: "element-choice",
            options: ELEMENT_OPTIONS
          },
          {
            id: "tatuagem-mistica",
            title: "Tatuagem Mística",
            description: "Escolha 1 magia de 1º círculo para aprender (atributo-chave: Carisma). Se aprender novamente, custo –1 PM",
            type: "multiple",
            minSelections: 1,
            maxSelections: 1,
            targetStep: "race",
            effectType: "spell-grant",
            options: first_circle_spell_options
          }
        ]
      end

      # ── Humano ───────────────────────────────────────────────────────────────

      def humano_choices
        [
          {
            id: "attr-bonus",
            title: "Bônus de Atributo",
            description: "Escolha 3 atributos diferentes para receber +1 em cada um",
            type: "multiple",
            minSelections: 3,
            maxSelections: 3,
            targetStep: "race",
            effectType: "attribute-bonus",
            options: ATTR_OPTIONS,
          },
          {
            id: "versatil-mode",
            title: "Versátil",
            description: "Escolha entre ganhar duas perícias treinadas ou uma perícia e um poder geral",
            type: "single",
            minSelections: 1,
            maxSelections: 1,
            targetStep: "race",
            effectType: "versatil-mode",
            options: [
              { id: "two-skills",      name: "Duas perícias treinadas",      description: "Escolha 2 perícias adicionais para treinar" },
              { id: "skill-and-power", name: "Uma perícia e um poder geral", description: "Escolha 1 perícia adicional e 1 poder geral" }
            ],
          },
        ]
      end

      # ── Osteon ───────────────────────────────────────────────────────────────

      def osteon_choices
        [
          {
            id: "attr-bonus",
            title: "Bônus de Atributo",
            description: "Escolha 2 atributos diferentes (exceto Constituição) para receber +1 em cada um",
            type: "multiple",
            minSelections: 2,
            maxSelections: 2,
            targetStep: "race",
            effectType: "attribute-bonus",
            options: ATTR_OPTIONS_NO_CON
          },
          {
            id: "memoria-postuma-mode",
            title: "Memória Póstuma",
            description: "Escolha entre treinar uma perícia, receber um poder geral, ou ganhar uma habilidade racial de outra raça humanoide",
            type: "single",
            minSelections: 1,
            maxSelections: 1,
            targetStep: "race",
            effectType: "memoria-postuma-mode",
            options: [
              { id: "trained-skill",             name: "Perícia treinada",               description: "Torne-se treinado em uma perícia à sua escolha (não precisa ser da sua classe)" },
              { id: "general-power",             name: "Poder geral",                    description: "Receba um poder geral à sua escolha" },
              { id: "racial-ability-other-race", name: "Habilidade racial de outra raça", description: "Escolha uma habilidade racial de outra raça humanoide (não humano)" }
            ],
          },
        ]
      end

      # ── Lefou ────────────────────────────────────────────────────────────────

      def lefou_choices
        [
          {
            id: "attr-bonus",
            title: "Bônus de Atributo",
            description: "Escolha 2 atributos diferentes (exceto Carisma) para receber +1 em cada um",
            type: "multiple",
            minSelections: 2,
            maxSelections: 2,
            targetStep: "race",
            effectType: "attribute-bonus",
            options: ATTR_OPTIONS_NO_CAR,
          },
          {
            id: "deformidade-mode",
            title: "Deformidade",
            description: "Receba +2 em duas perícias à sua escolha, ou +2 em uma perícia e um poder da Tormenta",
            type: "single",
            minSelections: 1,
            maxSelections: 1,
            targetStep: "race",
            effectType: "deformidade-mode",
            options: [
              { id: "two-skill-bonuses",  name: "+2 em duas perícias",                     description: "Escolha 2 perícias para receber +2 em cada uma" },
              { id: "skill-and-tormenta", name: "+2 em uma perícia e um poder da Tormenta", description: "Escolha 1 perícia para receber +2 e 1 poder da Tormenta" },
            ],
          },
        ]
      end

      # ── Shared DB helpers ────────────────────────────────────────────────────

      def general_power_options
        ::Tormenta20::Models::Poder
          .where(type: "poder_geral")
          .order(:name)
          .map { |p| { id: p.id, name: p.name, description: p.description } }
      end

      def first_circle_spell_options
        ::Tormenta20::Models::Magia
          .where(circle: 1)
          .order(:name)
          .map { |m| { id: m.id, name: m.name, description: m.description&.first(120) } }
      end
    end
  end
end
