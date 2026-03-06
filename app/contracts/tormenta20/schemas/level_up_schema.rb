# frozen_string_literal: true

module Tormenta20
  module Schemas
    ClassChoicesSchema = Dry::Schema.JSON do
      optional(:subclass_key).filled(:string)
      optional(:fighting_style).filled(:string)
      optional(:chosen_path).filled(:string)
      optional(:specialization).filled(:string)
      optional(:extra_data).hash
    end

    SkillPointsSchema = Dry::Schema.JSON do
      optional(:acrobacia).filled(:integer, gteq?: 0)
      optional(:adestramento).filled(:integer, gteq?: 0)
      optional(:atletismo).filled(:integer, gteq?: 0)
      optional(:atuacao).filled(:integer, gteq?: 0)
      optional(:cavalgar).filled(:integer, gteq?: 0)
      optional(:conhecimento).filled(:integer, gteq?: 0)
      optional(:cura).filled(:integer, gteq?: 0)
      optional(:diplomacia).filled(:integer, gteq?: 0)
      optional(:enganacao).filled(:integer, gteq?: 0)
      optional(:fortitude).filled(:integer, gteq?: 0)
      optional(:furtividade).filled(:integer, gteq?: 0)
      optional(:guerra).filled(:integer, gteq?: 0)
      optional(:iniciativa).filled(:integer, gteq?: 0)
      optional(:intimidacao).filled(:integer, gteq?: 0)
      optional(:intuicao).filled(:integer, gteq?: 0)
      optional(:investigacao).filled(:integer, gteq?: 0)
      optional(:jogatina).filled(:integer, gteq?: 0)
      optional(:ladinagem).filled(:integer, gteq?: 0)
      optional(:luta).filled(:integer, gteq?: 0)
      optional(:misticismo).filled(:integer, gteq?: 0)
      optional(:nobreza).filled(:integer, gteq?: 0)
      optional(:oficio).filled(:integer, gteq?: 0)
      optional(:percepcao).filled(:integer, gteq?: 0)
      optional(:pilotagem).filled(:integer, gteq?: 0)
      optional(:pontaria).filled(:integer, gteq?: 0)
      optional(:reflexos).filled(:integer, gteq?: 0)
      optional(:religiao).filled(:integer, gteq?: 0)
      optional(:sobrevivencia).filled(:integer, gteq?: 0)
      optional(:vontade).filled(:integer, gteq?: 0)
    end

    AbilitiesChosenSchema = Dry::Schema.JSON do
      optional(:class_abilities).array(:string)
      optional(:bonus_abilities).array(:string)
    end

    PowersChosenSchema = Dry::Schema.JSON do
      optional(:general_powers).array(:string)
      optional(:class_powers).array(:string)
      optional(:combat_powers).array(:string)
      optional(:destiny_powers).array(:string)
      optional(:torment_powers).array(:string)
      optional(:granted_powers).array(:string)
    end

    SpellsChosenSchema = Dry::Schema.JSON do
      optional(:known_spells).array do
        hash do
          required(:spell_key).filled(:string)
          required(:circle).filled(:integer, gteq?: 1, lteq?: 5)
          optional(:school).filled(:string)
        end
      end
      optional(:spell_slots_increase).hash
    end
  end
end
