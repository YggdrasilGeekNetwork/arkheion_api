# frozen_string_literal: true

module Tormenta20
  # Builds the wizard choice definitions for a given class.
  # Handles class-specific rules not encoded in the gem:
  #   - Arcanista: path choice (Bruxo/Feiticeiro/Mago), Feiticeiro linhagem, initial spells
  #   - Bardo:    school selection + 3 arcana/universal circle-1 spells from chosen school
  #   - Druida:   school selection + 3 divina/universal circle-1 spells from chosen school
  #   - Clérigo:  3 divina/universal circle-1 spells (no school selection)
  #
  # Returns an Array of hashes matching the ChoiceDefinition shape consumed
  # by the frontend wizard:
  #   { id, title, description, type, minSelections, maxSelections,
  #     targetStep, effectType, effectValue, options: [{id, name, description}] }
  class ClassChoicesBuilder
    LINHAGEM_OPTIONS = [
      {
        id: "draconico",
        name: "Linhagem Dracônica",
        description: "Um de seus antepassados foi um majestoso dragão. Escolha um tipo de dano (ácido, eletricidade, fogo ou frio). " \
                     "Básica: soma Carisma nos PV iniciais e redução de dano 5 ao tipo escolhido. " \
                     "Aprimorada: magias do tipo escolhido custam –1 PM e causam +1 ponto de dano por dado. " \
                     "Superior: soma o dobro do Carisma nos PV e se torna imune ao tipo escolhido."
      },
      {
        id: "feerica",
        name: "Linhagem Feérica",
        description: "Seu sangue foi tocado pelas fadas. " \
                     "Básica: fica treinado em Enganação e aprende uma magia de 1º círculo de encantamento ou ilusão. " \
                     "Aprimorada: CD das magias de encantamento e ilusão aumenta em +2 e custam –1 PM. " \
                     "Superior: recebe +2 em Carisma."
      },
      {
        id: "rubra",
        name: "Linhagem Rubra",
        description: "Seu sangue foi corrompido pela Tormenta. " \
                     "Básica: recebe um poder da Tormenta e pode perder outro atributo em vez de Carisma pelos poderes da Tormenta. " \
                     "Aprimorada: escolha uma magia para cada poder da Tormenta que tiver; essas magias custam –1 PM. " \
                     "Superior: recebe +4 PM para cada poder da Tormenta que tiver."
      }
    ].freeze

    DRACONICO_ELEMENT_OPTIONS = [
      { id: "acido",        name: "Ácido" },
      { id: "eletricidade", name: "Eletricidade" },
      { id: "fogo",         name: "Fogo" },
      { id: "frio",         name: "Frio" }
    ].freeze

    SPELL_SCHOOLS = {
      "abjur"  => "Abjuração",
      "adiv"   => "Adivinhação",
      "conv"   => "Convocação",
      "encan"  => "Encantamento",
      "evoc"   => "Evocação",
      "ilus"   => "Ilusão",
      "necro"  => "Necromancia",
      "trans"  => "Transmutação"
    }.freeze

    class << self
      def build(classe)
        case classe.id
        when "arcanista" then arcanista_choices
        when "bardo"     then bardo_choices
        when "clerigo"   then clerigo_choices
        when "druida"    then druida_choices
        else []
        end
      end

      private

      # ── Arcanista ────────────────────────────────────────────────────────────

      def arcanista_choices
        [
          {
            id: "caminho-do-arcanista",
            title: "Caminho do Arcanista",
            description: "Escolha como você canaliza suas magias. Essa escolha é permanente.",
            type: "single",
            minSelections: 1,
            maxSelections: 1,
            targetStep: "class",
            effectType: "caminho-do-arcanista",
            options: [
              {
                id: "bruxo",
                name: "Bruxo",
                description: "Lança magias através de um foco mágico. Atributo-chave: Inteligência."
              },
              {
                id: "feiticeiro",
                name: "Feiticeiro",
                description: "Magia inata. Escolha uma linhagem como origem de seus poderes. Aprende 1 magia a cada nível ímpar. Atributo-chave: Carisma."
              },
              {
                id: "mago",
                name: "Mago",
                description: "Estudo e memorização em um grimório. Começa com 4 magias e aprende 1 extra ao acessar novo círculo. Atributo-chave: Inteligência."
              }
            ]
          },
          {
            id: "linhagem-do-feiticeiro",
            title: "Linhagem do Feiticeiro",
            description: "Escolha a origem sobrenatural de seu poder inato",
            type: "single",
            minSelections: 1,
            maxSelections: 1,
            targetStep: "class",
            effectType: "linhagem-do-feiticeiro",
            dependsOn: "feiticeiro",
            options: LINHAGEM_OPTIONS
          },
          {
            id: "magias-iniciais-bruxo",
            title: "Magias Iniciais (Bruxo)",
            description: "Escolha 3 magias de 1º círculo para começar",
            type: "multiple",
            minSelections: 3,
            maxSelections: 3,
            targetStep: "class",
            effectType: "spell-grant",
            dependsOn: "bruxo",
            options: first_circle_spell_options
          },
          {
            id: "magias-iniciais-feiticeiro",
            title: "Magias Iniciais (Feiticeiro)",
            description: "Escolha 3 magias de 1º círculo para começar",
            type: "multiple",
            minSelections: 3,
            maxSelections: 3,
            targetStep: "class",
            effectType: "spell-grant",
            dependsOn: "feiticeiro",
            options: first_circle_spell_options
          },
          {
            id: "magias-iniciais-mago",
            title: "Magias Iniciais (Mago)",
            description: "Escolha 4 magias de 1º círculo para começar",
            type: "multiple",
            minSelections: 4,
            maxSelections: 4,
            targetStep: "class",
            effectType: "spell-grant",
            dependsOn: "mago",
            options: first_circle_spell_options
          },
          {
            id: "linhagem-draconico-elemento",
            title: "Elemento Dracônico",
            description: "Escolha o tipo de dano de sua herança dracônica",
            type: "single",
            minSelections: 1,
            maxSelections: 1,
            targetStep: "class",
            effectType: "element-choice",
            dependsOn: "draconico",
            options: DRACONICO_ELEMENT_OPTIONS
          },
          {
            id: "linhagem-feerica-magia",
            title: "Magia Feérica",
            description: "Escolha uma magia de 1º círculo de encantamento ou ilusão (arcana ou divina)",
            type: "single",
            minSelections: 1,
            maxSelections: 1,
            targetStep: "class",
            effectType: "spell-grant",
            dependsOn: "feerica",
            options: first_circle_enchantment_illusion_options
          },
          {
            id: "linhagem-rubra-poder",
            title: "Poder da Tormenta (Linhagem Rubra)",
            description: "Escolha um poder da Tormenta para receber",
            type: "single",
            minSelections: 1,
            maxSelections: 1,
            targetStep: "class",
            effectType: "spell-grant",
            dependsOn: "rubra",
            options: tormenta_power_options
          }
        ]
      end

      # ── Bardo ─────────────────────────────────────────────────────────────────
      # Arcane caster. Picks 3 schools, then chooses 3 circle-1 spells from
      # the combined pool of those schools (arcana + universal).

      def bardo_choices
        [escola_choice("arcana", max_schools: 3)] +
          per_school_spell_choices("arcana", 3)
      end

      # ── Clérigo ───────────────────────────────────────────────────────────────
      # Divine caster; no school selection required.
      # Spell pool: divina + universal circle-1.

      def clerigo_choices
        [
          {
            id: "magias-iniciais",
            title: "Magias Iniciais",
            description: "Escolha 3 magias de 1º círculo para começar",
            type: "multiple",
            minSelections: 3,
            maxSelections: 3,
            targetStep: "class",
            effectType: "spell-grant",
            options: first_circle_spells_for("divina")
          }
        ]
      end

      # ── Druida ────────────────────────────────────────────────────────────────
      # Divine caster. Picks 3 schools, then chooses 3 circle-1 spells from
      # the combined pool of those schools (divina + universal).

      def druida_choices
        [escola_choice("divina", max_schools: 3)] +
          per_school_spell_choices("divina", 3)
      end

      # ── Shared choice builders ───────────────────────────────────────────────

      # "Choose a school" choice. Available schools are those that have at
      # least one circle-1 spell of the class's PRIMARY type (arcana/divina).
      # Universal spells don't determine which schools exist for a caster —
      # they transcend that distinction.
      # max_schools: how many schools the player must pick (1 = single, >1 = multiple)
      def escola_choice(primary_type, max_schools: 1)
        available = SPELL_SCHOOLS.select do |school_id, _|
          ::Tormenta20::Models::Magia.where(circle: 1, school: school_id, type: primary_type).exists?
        end
        plural = max_schools > 1
        {
          id: "escola-de-magias",
          title: plural ? "Escolas de Magia" : "Escola de Magia",
          description: "Escolha #{max_schools} escola#{plural ? 's' : ''} de magia para suas magias iniciais",
          type: plural ? "multiple" : "single",
          minSelections: max_schools,
          maxSelections: max_schools,
          targetStep: "class",
          effectType: "escola-de-magias",
          options: available.map { |id, name| { id: id, name: name } }
        }
      end

      # One spell-selection choice per school. Spell pool for each school:
      # primary type + universal (universal spells are available to all casters).
      # Only schools with at least one such spell are included.
      def per_school_spell_choices(primary_type, count)
        SPELL_SCHOOLS.filter_map do |school_id, school_name|
          spells = first_circle_spells_by_school(school_id, primary_type)
          next if spells.empty?

          {
            id: "magias-iniciais-#{school_id}",
            title: "Magias Iniciais — #{school_name}",
            description: "Escolha #{count} magia#{count > 1 ? 's' : ''} de 1º círculo de #{school_name}",
            type: "multiple",
            minSelections: count,
            maxSelections: count,
            targetStep: "class",
            effectType: "spell-grant",
            dependsOn: school_id,
            options: spells
          }
        end
      end

      # ── Shared DB helpers ────────────────────────────────────────────────────

      # All circle-1 spells for a caster type: primary type + universal.
      # Universal spells are available to all casters regardless of their type.
      def first_circle_spells_for(primary_type)
        ::Tormenta20::Models::Magia
          .where(circle: 1, type: [primary_type, "universal"])
          .order(:name)
          .map { |m| spell_option(m) }
      end

      # Circle-1 spells for a school: primary type + universal.
      def first_circle_spells_by_school(school_id, primary_type)
        ::Tormenta20::Models::Magia
          .where(circle: 1, school: school_id, type: [primary_type, "universal"])
          .order(:name)
          .map { |m| spell_option(m) }
      end

      # Arcane and universal 1st-circle spells (Arcanista path choices)
      def first_circle_spell_options
        first_circle_spells_for("arcana")
      end

      # Enchantment and illusion 1st-circle spells (Linhagem Feérica)
      def first_circle_enchantment_illusion_options
        ::Tormenta20::Models::Magia
          .where(circle: 1, school: %w[encan ilus])
          .order(:name)
          .map { |m| spell_option(m) }
      end

      def spell_option(magia)
        {
          id: magia.id,
          name: magia.name,
          description: magia.description,
          school: magia.school,
          schoolName: SPELL_SCHOOLS[magia.school]
        }
      end

      # Tormenta powers (Linhagem Rubra)
      def tormenta_power_options
        ::Tormenta20::Models::Poder
          .where(type: "poder_tormenta")
          .order(:name)
          .map { |p| { id: p.id, name: p.name, description: p.description&.first(120) } }
      end
    end
  end
end
