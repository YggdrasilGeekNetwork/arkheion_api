# frozen_string_literal: true

module Types
  module Tormenta20
    # ─── Sub-types ────────────────────────────────────────────────────────────

    class RulebookClasseType < Types::BaseObject
      description "Character class from the Tormenta20 gem"
      field :id,            String,  null: false
      field :name,          String,  null: false
      field :description,   String,  null: true
      field :hit_points,    GraphQL::Types::JSON, null: true
      field :mana_points,   GraphQL::Types::JSON, null: true
      field :skills,        GraphQL::Types::JSON, null: true
      field :proficiencies, GraphQL::Types::JSON, null: true
      field :abilities,     [String], null: true
      field :powers,        [String], null: true
      field :progression,   GraphQL::Types::JSON, null: true
      field :spellcasting,  GraphQL::Types::JSON, null: true
    end

    class RulebookRacaType < Types::BaseObject
      description "Playable race from the Tormenta20 gem"
      field :id,                        String,  null: false
      field :name,                      String,  null: false
      field :description,               String,  null: true
      field :size,                      String,  null: true
      field :movement,                  Integer, null: true
      field :vision,                    String,  null: true
      field :vision_range,              Integer, null: true
      field :attribute_bonuses,         GraphQL::Types::JSON, null: true
      field :racial_abilities,          [String], null: true
      field :chosen_abilities_amount,   Integer, null: true
      field :available_chosen_abilities, [String], null: true
    end

    class RulebookOrigemType < Types::BaseObject
      description "Character origin from the Tormenta20 gem"
      field :id,           String,  null: false
      field :name,         String,  null: false
      field :description,  String,  null: true
      field :items,        GraphQL::Types::JSON, null: true
      field :benefits,     GraphQL::Types::JSON, null: true
      field :unique_power, String,  null: true
    end

    class RulebookDivindadeType < Types::BaseObject
      description "Deity from the Tormenta20 gem"
      field :id,                      String,  null: false
      field :name,                    String,  null: false
      field :title,                   String,  null: true
      field :description,             String,  null: true
      field :beliefs_objectives,      String,  null: true
      field :holy_symbol,             String,  null: true
      field :energy,                  String,  null: true
      field :preferred_weapon,        String,  null: true
      field :devotees,                String,  null: true
      field :granted_powers,          GraphQL::Types::JSON, null: true
      field :obligations_restrictions, String,  null: true
    end

    class RulebookPoderType < Types::BaseObject
      description "Power or ability from the Tormenta20 gem"
      field :id,           String,  null: false
      field :name,         String,  null: false
      field :kind,         String,  null: true, method: :type
      field :description,  String,  null: true
      field :effects,      GraphQL::Types::JSON, null: true
      field :prerequisites, [String], null: true
      field :class_id,     String,  null: true
      field :origin_id,    String,  null: true
    end

    class RulebookMagiaType < Types::BaseObject
      description "Spell from the Tormenta20 gem"
      field :id,               String,  null: false
      field :name,             String,  null: false
      field :kind,             String,  null: true, method: :type
      field :circle,           Integer, null: true
      field :school,           String,  null: true
      field :execution,        String,  null: true
      field :execution_details, String, null: true
      field :range,            String,  null: true
      field :duration,         String,  null: true
      field :duration_details, String,  null: true
      field :counterspell,     String,  null: true
      field :description,      String,  null: false
      field :enhancements,     GraphQL::Types::JSON, null: true
      field :effects,          GraphQL::Types::JSON, null: true
    end

    class RulebookArmaType < Types::BaseObject
      description "Weapon from the Tormenta20 gem"
      field :id,          String,  null: false
      field :name,        String,  null: false
      field :category,    String,  null: true
      field :damage,      String,  null: true
      field :damage_type, String,  null: true
      field :critical,    String,  null: true
      field :range,       String,  null: true
      field :weight,      String,  null: true
      field :properties,  GraphQL::Types::JSON, null: true
      field :description, String,  null: true
    end

    class RulebookArmaduraType < Types::BaseObject
      description "Armor from the Tormenta20 gem"
      field :id,            String,  null: false
      field :name,          String,  null: false
      field :defense_bonus, Integer, null: true
      field :armor_penalty, Integer, null: true
      field :weight,        String,  null: true
      field :price,         String,  null: true
      field :properties,    GraphQL::Types::JSON, null: true
      field :description,   String,  null: true
    end

    class RulebookEscudoType < Types::BaseObject
      description "Shield from the Tormenta20 gem"
      field :id,            String,  null: false
      field :name,          String,  null: false
      field :defense_bonus, Integer, null: true
      field :armor_penalty, Integer, null: true
      field :weight,        String,  null: true
      field :price,         String,  null: true
      field :description,   String,  null: true
    end

    class RulebookRegraType < Types::BaseObject
      description "Rule or reference entry from the Tormenta20 gem"
      field :id,          String,  null: false
      field :name,        String,  null: false
      field :description, String,  null: true
      field :data,        GraphQL::Types::JSON, null: true
    end

    class RulebookMaterialEspecialType < Types::BaseObject
      description "Special material from the Tormenta20 gem"
      field :id,             String,  null: false
      field :name,           String,  null: false
      field :description,    String,  null: true
      field :applicable_to,  GraphQL::Types::JSON, null: true
      field :price_modifier, String,  null: true
      field :effects,        GraphQL::Types::JSON, null: true
    end

    class RulebookCondicaoType < Types::BaseObject
      description "Status condition from the Tormenta20 gem"
      field :id,             String,   null: false
      field :name,           String,   null: false
      field :description,    String,   null: true
      field :effects,        [String], null: true
      field :condition_type, String,   null: true
      field :escalates_to,   String,   null: true
    end

    # ─── Main RulebookType ────────────────────────────────────────────────────

    class RulebookType < Types::BaseObject
      description "Proxy to all Tormenta20 gem data for quick reference (DM screen)"

      field :classes, [RulebookClasseType], null: false do
        argument :search, String, required: false
      end

      field :racas, [RulebookRacaType], null: false do
        argument :search, String, required: false
      end

      field :origens, [RulebookOrigemType], null: false do
        argument :search, String, required: false
      end

      field :divindades, [RulebookDivindadeType], null: false do
        argument :search, String, required: false
      end

      field :poderes, [RulebookPoderType], null: false do
        argument :search, String, required: false
        argument :kind,   String, required: false
      end

      field :magias, [RulebookMagiaType], null: false do
        argument :search, String,  required: false
        argument :kind,   String,  required: false
        argument :circle, Integer, required: false
      end

      field :armas, [RulebookArmaType], null: false do
        argument :search,   String, required: false
        argument :category, String, required: false
      end

      field :armaduras, [RulebookArmaduraType], null: false do
        argument :search, String, required: false
      end

      field :escudos, [RulebookEscudoType], null: false

      field :materiais_especiais, [RulebookMaterialEspecialType], null: false do
        argument :search, String, required: false
      end

      field :regras, [RulebookRegraType], null: false do
        argument :search, String, required: false
      end

      field :condicoes, [RulebookCondicaoType], null: false do
        argument :search,         String, required: false
        argument :condition_type, String, required: false
      end

      # ─── Resolvers ──────────────────────────────────────────────────────────

      def classes(search: nil)
        scope = ::Tormenta20::Models::Classe.all
        scope = scope.where("name LIKE ?", "%#{search}%") if search.present?
        scope.order(:name)
      end

      def racas(search: nil)
        scope = ::Tormenta20::Models::Raca.all
        scope = scope.where("name LIKE ?", "%#{search}%") if search.present?
        scope.order(:name)
      end

      def origens(search: nil)
        scope = ::Tormenta20::Models::Origem.all
        scope = scope.where("name LIKE ?", "%#{search}%") if search.present?
        scope.order(:name)
      end

      def divindades(search: nil)
        scope = ::Tormenta20::Models::Divindade.all
        scope = scope.where("name LIKE ?", "%#{search}%") if search.present?
        scope.order(:name)
      end

      def poderes(search: nil, kind: nil)
        scope = ::Tormenta20::Models::Poder.all
        scope = scope.where("name LIKE ?", "%#{search}%") if search.present?
        scope = scope.where(type: kind) if kind.present?
        scope.order(:name)
      end

      def magias(search: nil, kind: nil, circle: nil)
        scope = ::Tormenta20::Models::Magia.all
        scope = scope.where("name LIKE ?", "%#{search}%") if search.present?
        scope = scope.where(type: kind) if kind.present?
        scope = scope.where(circle: circle) if circle.present?
        scope.order(:circle, :name)
      end

      def armas(search: nil, category: nil)
        scope = ::Tormenta20::Models::Arma.all
        scope = scope.where("name LIKE ?", "%#{search}%") if search.present?
        scope = scope.where(category: category) if category.present?
        scope.order(:category, :name)
      end

      def armaduras(search: nil)
        scope = ::Tormenta20::Models::Armadura.all
        scope = scope.where("name LIKE ?", "%#{search}%") if search.present?
        scope.order(:name)
      end

      def escudos
        ::Tormenta20::Models::Escudo.all.order(:name)
      end

      def materiais_especiais(search: nil)
        scope = ::Tormenta20::Models::MaterialEspecial.all
        scope = scope.where("name LIKE ?", "%#{search}%") if search.present?
        scope.order(:name)
      end

      def regras(search: nil)
        scope = ::Tormenta20::Models::Regra.all
        scope = scope.where("name LIKE ?", "%#{search}%") if search.present?
        scope.order(:name)
      end

      def condicoes(search: nil, condition_type: nil)
        scope = ::Tormenta20::Models::Condicao.all
        scope = scope.where("name LIKE ?", "%#{search}%") if search.present?
        scope = scope.where(condition_type: condition_type) if condition_type.present?
        scope.order(:name)
      end
    end
  end
end
