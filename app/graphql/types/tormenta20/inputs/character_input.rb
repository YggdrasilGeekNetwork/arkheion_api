# frozen_string_literal: true

module Types
  module Tormenta20
    module Inputs
      # ─── Basic Info ───────────────────────────────────────────────────────────

      class CharacterClassInput < Types::BaseInputObject
        argument :name,    String,  required: true
        argument :level,   Integer, required: true
        argument :tooltip, String,  required: false
      end

      class CharacterInfoInput < Types::BaseInputObject
        argument :name,    String, required: true
        argument :tooltip, String, required: false
      end

      # ─── Attributes & Defenses ───────────────────────────────────────────────

      class AttributeInput < Types::BaseInputObject
        argument :label,    String,  required: true
        argument :value,    Integer, required: true
        argument :modifier, Integer, required: true
        argument :visible,  Boolean, required: true
      end

      class ResistanceInput < Types::BaseInputObject
        argument :name,    String,  required: true
        argument :value,   Integer, required: true
        argument :tooltip, String,  required: true
        argument :visible, Boolean, required: true
      end

      class DefenseInput < Types::BaseInputObject
        argument :name,    String,  required: true
        argument :value,   Integer, required: true
        argument :tooltip, String,  required: true
      end

      # ─── Skills ───────────────────────────────────────────────────────────────

      class BonusEntryInput < Types::BaseInputObject
        argument :label, String,  required: true
        argument :value, Integer, required: true
      end

      class SkillInput < Types::BaseInputObject
        argument :name,               String,  required: true
        argument :modifier,           Integer, required: true
        argument :trained,            Boolean, required: true
        argument :attribute,          String,  required: true
        argument :tooltip,            String,  required: false
        argument :visible_in_combat,  Boolean, required: false
        argument :visible_in_summary, Boolean, required: false
        argument :level_bonus,        Integer, required: false
        argument :training_bonus,     Integer, required: false
        argument :other_bonuses,      [BonusEntryInput], required: false
      end

      # ─── Combat ───────────────────────────────────────────────────────────────

      class AvailableActionsInput < Types::BaseInputObject
        argument :standard, Integer, required: true
        argument :movement, Integer, required: true
        argument :free,     Integer, required: true
        argument :full,     Integer, required: true
        argument :reaction, Integer, required: true
      end

      class ActionCostInput < Types::BaseInputObject
        argument :pm, Integer, required: false
        argument :pv, Integer, required: false
      end

      class CombatActionInput < Types::BaseInputObject
        argument :id,             ID,      required: true
        argument :name,           String,  required: true
        argument :type,           String,  required: true
        argument :cost,           ActionCostInput, required: false
        argument :effect,         String,  required: true
        argument :tooltip,        String,  required: false
        argument :modal,          Boolean, required: false
        argument :choices,        [String], required: false
        argument :is_favorite,    Boolean, required: false
        argument :favorite_order, Integer, required: false
        argument :uses_per_turn,  Integer, required: false
        argument :resistance,     String,  required: false
      end

      class WeaponAttackInput < Types::BaseInputObject
        argument :id,               ID,      required: true
        argument :name,             String,  required: true
        argument :damage,           String,  required: true
        argument :damage_type,      String,  required: false
        argument :attack_bonus,     Integer, required: true
        argument :attack_attribute, String,  required: false
        argument :crit_range,       String,  required: false
        argument :crit_multiplier,  String,  required: false
        argument :range,            String,  required: false
        argument :action_type,      String,  required: true
        argument :is_favorite,      Boolean, required: false
        argument :favorite_order,   Integer, required: false
        argument :equipment_id,     ID,      required: false
      end

      # ─── Abilities ────────────────────────────────────────────────────────────

      class AbilityInput < Types::BaseInputObject
        argument :id,             ID,     required: true
        argument :name,           String, required: true
        argument :description,    String, required: true
        argument :type,           String, required: true
        argument :action_type,    String, required: false
        argument :cost,           ActionCostInput, required: false
        argument :uses_per_day,   Integer, required: false
        argument :source,         String,  required: false
        argument :is_favorite,    Boolean, required: false
        argument :favorite_order, Integer, required: false
      end

      # ─── Spells ───────────────────────────────────────────────────────────────

      class SpellTargetInput < Types::BaseInputObject
        argument :amount, Integer, required: false
        argument :up_to,  Integer, required: false
        argument :type,   String,  required: true
      end

      class SpellEffectInput < Types::BaseInputObject
        argument :type,                   String, required: true
        argument :attribute,              String, required: false
        argument :amount,                 String, required: false
        argument :resistance_requirement, String, required: false
        argument :extra_requirements,     String, required: false
      end

      class SpellEnhancementDetailsInput < Types::BaseInputObject
        argument :execution, String,           required: false
        argument :duration,  String,           required: false
        argument :circle,    Integer,          required: false
        argument :effects,   [SpellEffectInput], required: false
      end

      class SpellEnhancementInput < Types::BaseInputObject
        argument :cost,         Integer, required: true
        argument :type,         String,  required: true
        argument :description,  String,  required: true
        argument :extra_details, SpellEnhancementDetailsInput, required: false
      end

      class SpellInput < Types::BaseInputObject
        argument :id,                  ID,      required: true
        argument :name,                String,  required: true
        argument :type,                String,  required: true
        argument :circle,              Integer, required: true
        argument :school,              String,  required: true
        argument :execution,           String,  required: true
        argument :execution_details,   String,  required: false
        argument :range,               String,  required: true
        argument :target,              SpellTargetInput, required: false
        argument :area_effect,         String,  required: false
        argument :area_effect_details, String,  required: false
        argument :counterspell,        String,  required: false
        argument :duration,            String,  required: true
        argument :duration_details,    String,  required: false
        argument :resistance,          String,  required: false
        argument :extra_costs,         String,  required: false
        argument :description,         String,  required: true
        argument :enhancements,        [SpellEnhancementInput], required: false
        argument :effects,             [SpellEffectInput],      required: false
        argument :is_favorite,         Boolean, required: false
        argument :favorite_order,      Integer, required: false
      end

      # ─── Equipment ────────────────────────────────────────────────────────────

      class ItemModAttributeInput < Types::BaseInputObject
        argument :label, String,  required: true
        argument :bonus, Integer, required: true
      end

      class ItemModValueInput < Types::BaseInputObject
        argument :type,  String,  required: true
        argument :bonus, Integer, required: true
      end

      class ItemModSkillInput < Types::BaseInputObject
        argument :name,  String,  required: true
        argument :bonus, Integer, required: true
      end

      class ItemModOtherInput < Types::BaseInputObject
        argument :label, String, required: true
        argument :value, String, required: true
      end

      class ItemPassiveModifiersInput < Types::BaseInputObject
        argument :attribute,  ItemModAttributeInput, required: false
        argument :defense,    ItemModValueInput,     required: false
        argument :resistance, ItemModValueInput,     required: false
        argument :skill,      ItemModSkillInput,     required: false
        argument :other,      ItemModOtherInput,     required: false
      end

      class ItemActiveAbilityInput < Types::BaseInputObject
        argument :name,         String, required: true
        argument :description,  String, required: true
        argument :action_type,  String, required: true
        argument :cost,         ActionCostInput, required: false
        argument :uses_per_day, Integer, required: false
        argument :consume_item, Boolean, required: false
      end

      class ItemEffectInput < Types::BaseInputObject
        argument :id,                ID,     required: true
        argument :name,              String, required: true
        argument :description,       String, required: true
        argument :type,              String, required: true
        argument :passive_modifiers, ItemPassiveModifiersInput, required: false
        argument :active_ability,    ItemActiveAbilityInput,    required: false
      end

      class EquipmentItemInput < Types::BaseInputObject
        argument :id,               ID,     required: true
        argument :name,             String, required: true
        argument :description,      String,  required: false
        argument :quantity,         Integer, required: false
        argument :weight,           Float,   required: false
        argument :spaces,           Float,   required: false
        argument :price,            Integer, required: false
        argument :category,         String,  required: false
        argument :effects,          [ItemEffectInput], required: false
        argument :allowed_slots,    [String], required: false
        argument :two_handed,       Boolean, required: false
        argument :versatile,        Boolean, required: false
        argument :using_two_handed, Boolean, required: false
      end

      class EquippedItemsInput < Types::BaseInputObject
        argument :right_hand,  EquipmentItemInput, required: false
        argument :left_hand,   EquipmentItemInput, required: false
        argument :quick_draw1, EquipmentItemInput, required: false
        argument :quick_draw2, EquipmentItemInput, required: false
        argument :slot1,       EquipmentItemInput, required: false
        argument :slot2,       EquipmentItemInput, required: false
        argument :slot3,       EquipmentItemInput, required: false
        argument :slot4,       EquipmentItemInput, required: false
      end

      class CurrenciesInput < Types::BaseInputObject
        argument :tc, Integer, required: true
        argument :tp, Integer, required: true
        argument :to, Integer, required: true
      end

      # ─── Choices-based inputs (for Characters::Create) ────────────────────────

      class SheetAttributesInput < Types::BaseInputObject
        argument :forca,        Integer, required: true
        argument :destreza,     Integer, required: true
        argument :constituicao, Integer, required: true
        argument :inteligencia, Integer, required: true
        argument :sabedoria,    Integer, required: true
        argument :carisma,      Integer, required: true
      end

      class CreateRaceChoicesInput < Types::BaseInputObject
        argument :chosen_abilities,         [String], required: false
        argument :chosen_attribute_bonuses, GraphQL::Types::JSON, required: false
      end

      class CreateOriginChoicesInput < Types::BaseInputObject
        argument :chosen_skills,       [String], required: false
        argument :chosen_powers,       [String], required: false
        argument :chosen_proficiencies, [String], required: false
        argument :chosen_items,        [String], required: false
      end

      class FirstLevelInput < Types::BaseInputObject
        argument :class_key,        String, required: true
        argument :skill_points,     GraphQL::Types::JSON, required: false
        argument :abilities_chosen, GraphQL::Types::JSON, required: false
        argument :powers_chosen,    GraphQL::Types::JSON, required: false
        argument :spells_chosen,    GraphQL::Types::JSON, required: false
        argument :class_choices,    GraphQL::Types::JSON, required: false
      end

      # ─── Top-level Inputs ─────────────────────────────────────────────────────

      class CreateCharacterInput < Types::BaseInputObject
        argument :name,           String,            required: true
        argument :image_url,      String,            required: false
        argument :race_key,       String,            required: true
        argument :race_choices,   CreateRaceChoicesInput,   required: false
        argument :origin_key,     String,                   required: true
        argument :origin_choices, CreateOriginChoicesInput, required: false
        argument :deity_key,      String,            required: false
        argument :sheet_attributes, SheetAttributesInput, required: true
        argument :first_level,    FirstLevelInput,   required: true
      end

      class LevelUpCharacterInput < Types::BaseInputObject
        argument :class_key,        String, required: true
        argument :skill_points,     GraphQL::Types::JSON, required: false
        argument :abilities_chosen, GraphQL::Types::JSON, required: false
        argument :powers_chosen,    GraphQL::Types::JSON, required: false
        argument :spells_chosen,    GraphQL::Types::JSON, required: false
        argument :class_choices,    GraphQL::Types::JSON, required: false
      end
    end
  end
end
