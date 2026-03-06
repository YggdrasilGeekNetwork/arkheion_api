# frozen_string_literal: true

module Tormenta20
  module Schemas
    ComputedAttributesSchema = Dry::Schema.JSON do
      required(:forca).hash do
        required(:base).filled(:integer)
        required(:modifier).filled(:integer)
        required(:total).filled(:integer)
        optional(:bonuses).array do
          hash do
            required(:source).filled(:string)
            required(:value).filled(:integer)
          end
        end
      end

      required(:destreza).hash do
        required(:base).filled(:integer)
        required(:modifier).filled(:integer)
        required(:total).filled(:integer)
        optional(:bonuses).array
      end

      required(:constituicao).hash do
        required(:base).filled(:integer)
        required(:modifier).filled(:integer)
        required(:total).filled(:integer)
        optional(:bonuses).array
      end

      required(:inteligencia).hash do
        required(:base).filled(:integer)
        required(:modifier).filled(:integer)
        required(:total).filled(:integer)
        optional(:bonuses).array
      end

      required(:sabedoria).hash do
        required(:base).filled(:integer)
        required(:modifier).filled(:integer)
        required(:total).filled(:integer)
        optional(:bonuses).array
      end

      required(:carisma).hash do
        required(:base).filled(:integer)
        required(:modifier).filled(:integer)
        required(:total).filled(:integer)
        optional(:bonuses).array
      end
    end

    ComputedDefensesSchema = Dry::Schema.JSON do
      required(:defesa).hash do
        required(:base).filled(:integer)
        required(:total).filled(:integer)
        optional(:armor_bonus).filled(:integer)
        optional(:shield_bonus).filled(:integer)
        optional(:dexterity_bonus).filled(:integer)
        optional(:other_bonuses).array
      end

      required(:fortitude).hash do
        required(:base).filled(:integer)
        required(:total).filled(:integer)
        optional(:attribute_bonus).filled(:integer)
        optional(:other_bonuses).array
      end

      required(:reflexos).hash do
        required(:base).filled(:integer)
        required(:total).filled(:integer)
        optional(:attribute_bonus).filled(:integer)
        optional(:other_bonuses).array
      end

      required(:vontade).hash do
        required(:base).filled(:integer)
        required(:total).filled(:integer)
        optional(:attribute_bonus).filled(:integer)
        optional(:other_bonuses).array
      end
    end

    ComputedSkillSchema = Dry::Schema.JSON do
      required(:ranks).filled(:integer)
      required(:attribute_modifier).filled(:integer)
      required(:total).filled(:integer)
      required(:trained).filled(:bool)
      optional(:other_bonuses).array
    end

    ComputedCombatSchema = Dry::Schema.JSON do
      required(:base_attack_bonus).filled(:integer)

      required(:melee_attack).hash do
        required(:total).filled(:integer)
        required(:attribute_modifier).filled(:integer)
        optional(:other_bonuses).array
      end

      required(:ranged_attack).hash do
        required(:total).filled(:integer)
        required(:attribute_modifier).filled(:integer)
        optional(:other_bonuses).array
      end

      optional(:weapons).array do
        hash do
          required(:name).filled(:string)
          required(:attack_bonus).filled(:integer)
          required(:damage).filled(:string)
          required(:critical).filled(:string)
          optional(:damage_type).filled(:string)
          optional(:range).filled(:string)
          optional(:properties).array(:string)
        end
      end
    end

    ComputedResourcesSchema = Dry::Schema.JSON do
      required(:pv).hash do
        required(:max).filled(:integer)
        required(:base).filled(:integer)
        optional(:constitution_bonus).filled(:integer)
        optional(:other_bonuses).array
      end

      required(:pm).hash do
        required(:max).filled(:integer)
        required(:base).filled(:integer)
        optional(:attribute_bonus).filled(:integer)
        optional(:other_bonuses).array
      end

      required(:deslocamento).hash do
        required(:base).filled(:integer)
        required(:total).filled(:integer)
        optional(:armor_penalty).filled(:integer)
        optional(:other_bonuses).array
      end
    end

    ComputedAbilitySchema = Dry::Schema.JSON do
      required(:ability_key).filled(:string)
      required(:name).filled(:string)
      required(:source).filled(:string)
      optional(:description).filled(:string)
      optional(:uses_per_day).filled(:integer)
      optional(:action_type).filled(:string)
      optional(:extra_data).hash
    end

    ComputedSpellSchema = Dry::Schema.JSON do
      required(:spell_key).filled(:string)
      required(:name).filled(:string)
      required(:circle).filled(:integer)
      required(:school).filled(:string)
      optional(:casting_time).filled(:string)
      optional(:range).filled(:string)
      optional(:duration).filled(:string)
      optional(:description).filled(:string)
      optional(:save_dc).filled(:integer)
    end
  end
end
