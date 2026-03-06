# frozen_string_literal: true

module Types
  module Tormenta20
    # ─── Sub-types ────────────────────────────────────────────────────────────

    class CharacterClassType < Types::BaseObject
      field :name,    String,  null: false
      field :level,   Integer, null: false
      field :tooltip, String,  null: true
    end

    class CharacterInfoType < Types::BaseObject
      field :name,    String, null: false
      field :tooltip, String, null: true
    end

    class FrontendAttributeType < Types::BaseObject
      field :label,    String,  null: false
      field :value,    Integer, null: false
      field :modifier, Integer, null: false
      field :visible,  Boolean, null: false
    end

    class FrontendResistanceType < Types::BaseObject
      field :name,    String,  null: false
      field :value,   Integer, null: false
      field :tooltip, String,  null: false
      field :visible, Boolean, null: false
    end

    class FrontendDefenseType < Types::BaseObject
      field :name,    String,  null: false
      field :value,   Integer, null: false
      field :tooltip, String,  null: false
    end

    class FrontendBonusEntryType < Types::BaseObject
      field :label, String,  null: false
      field :value, Integer, null: false
    end

    class FrontendSkillType < Types::BaseObject
      field :name,               String,  null: false
      field :modifier,           Integer, null: false
      field :trained,            Boolean, null: false
      field :attribute,          String,  null: false
      field :tooltip,            String,  null: true
      field :visible_in_combat,  Boolean, null: true
      field :visible_in_summary, Boolean, null: true
      field :level_bonus,        Integer, null: true
      field :training_bonus,     Integer, null: true
      field :other_bonuses,      [FrontendBonusEntryType], null: true
    end

    class FrontendAvailableActionsType < Types::BaseObject
      field :standard, Integer, null: false
      field :movement, Integer, null: false
      field :free,     Integer, null: false
      field :full,     Integer, null: false
      field :reaction, Integer, null: false
    end

    class FrontendActionCostType < Types::BaseObject
      field :pm, Integer, null: true
      field :pv, Integer, null: true
    end

    class FrontendCombatActionType < Types::BaseObject
      field :id,             ID,      null: false
      field :name,           String,  null: false
      field :type,           String,  null: false
      field :cost,           FrontendActionCostType, null: true
      field :effect,         String,  null: false
      field :tooltip,        String,  null: true
      field :modal,          Boolean, null: true
      field :choices,        [String], null: true
      field :is_favorite,    Boolean, null: true
      field :favorite_order, Integer, null: true
      field :uses_per_turn,  Integer, null: true
      field :used_this_turn, Integer, null: true
      field :resistance,     String,  null: true
    end

    class FrontendWeaponAttackType < Types::BaseObject
      field :id,               ID,      null: false
      field :name,             String,  null: false
      field :damage,           String,  null: false
      field :damage_type,      String,  null: true
      field :attack_bonus,     Integer, null: false
      field :attack_attribute, String,  null: true
      field :crit_range,       String,  null: true
      field :crit_multiplier,  String,  null: true
      field :range,            String,  null: true
      field :action_type,      String,  null: false
      field :is_favorite,      Boolean, null: true
      field :favorite_order,   Integer, null: true
      field :equipment_id,     ID,      null: true
    end

    class FrontendAbilityType < Types::BaseObject
      field :id,             ID,      null: false
      field :name,           String,  null: false
      field :description,    String,  null: false
      field :type,           String,  null: false
      field :action_type,    String,  null: true
      field :cost,           FrontendActionCostType, null: true
      field :uses_per_day,   Integer, null: true
      field :source,         String,  null: true
      field :is_favorite,    Boolean, null: true
      field :favorite_order, Integer, null: true
    end

    # ─── Spell sub-types ──────────────────────────────────────────────────────

    class SpellTargetOutputType < Types::BaseObject
      field :amount, Integer, null: true
      field :up_to,  Integer, null: true
      field :type,   String,  null: false
    end

    class SpellEffectOutputType < Types::BaseObject
      field :type,                   String, null: false
      field :attribute,              String, null: true
      field :amount,                 String, null: true
      field :resistance_requirement, String, null: true
      field :extra_requirements,     String, null: true
    end

    class SpellEnhancementDetailsOutputType < Types::BaseObject
      field :execution, String,                  null: true
      field :duration,  String,                  null: true
      field :circle,    Integer,                 null: true
      field :effects,   [SpellEffectOutputType], null: true
    end

    class SpellEnhancementOutputType < Types::BaseObject
      field :cost,         Integer,                           null: false
      field :type,         String,                            null: false
      field :description,  String,                            null: false
      field :extra_details, SpellEnhancementDetailsOutputType, null: true
    end

    class FrontendSpellType < Types::BaseObject
      field :id,                  ID,      null: false
      field :name,                String,  null: false
      field :type,                String,  null: false
      field :circle,              Integer, null: false
      field :school,              String,  null: false
      field :execution,           String,  null: false
      field :execution_details,   String,  null: true
      field :range,               String,  null: false
      field :target,              SpellTargetOutputType,       null: true
      field :area_effect,         String,  null: true
      field :area_effect_details, String,  null: true
      field :counterspell,        String,  null: true
      field :duration,            String,  null: false
      field :duration_details,    String,  null: true
      field :resistance,          String,  null: true
      field :extra_costs,         String,  null: true
      field :description,         String,  null: false
      field :enhancements,        [SpellEnhancementOutputType], null: true
      field :effects,             [SpellEffectOutputType],      null: true
      field :is_favorite,         Boolean, null: true
      field :favorite_order,      Integer, null: true
    end

    # ─── Equipment sub-types ──────────────────────────────────────────────────

    class ItemModAttributeOutputType < Types::BaseObject
      field :label, String,  null: false
      field :bonus, Integer, null: false
    end

    class ItemModValueOutputType < Types::BaseObject
      field :type,  String,  null: false
      field :bonus, Integer, null: false
    end

    class ItemModSkillOutputType < Types::BaseObject
      field :name,  String,  null: false
      field :bonus, Integer, null: false
    end

    class ItemModOtherOutputType < Types::BaseObject
      field :label, String, null: false
      field :value, String, null: false
    end

    class ItemPassiveModifiersOutputType < Types::BaseObject
      field :attribute,  ItemModAttributeOutputType, null: true
      field :defense,    ItemModValueOutputType,     null: true
      field :resistance, ItemModValueOutputType,     null: true
      field :skill,      ItemModSkillOutputType,     null: true
      field :other,      ItemModOtherOutputType,     null: true
    end

    class ItemActiveAbilityOutputType < Types::BaseObject
      field :name,         String,  null: false
      field :description,  String,  null: false
      field :action_type,  String,  null: false
      field :cost,         FrontendActionCostType, null: true
      field :uses_per_day, Integer, null: true
      field :consume_item, Boolean, null: true
    end

    class FrontendItemEffectType < Types::BaseObject
      field :id,                ID,      null: false
      field :name,              String,  null: false
      field :description,       String,  null: false
      field :type,              String,  null: false
      field :passive_modifiers, ItemPassiveModifiersOutputType, null: true
      field :active_ability,    ItemActiveAbilityOutputType,    null: true
    end

    class FrontendEquipmentItemType < Types::BaseObject
      field :id,               ID,      null: false
      field :name,             String,  null: false
      field :description,      String,  null: true
      field :quantity,         Integer, null: true
      field :weight,           Float,   null: true
      field :spaces,           Integer, null: true
      field :price,            Integer, null: true
      field :category,         String,  null: true
      field :effects,          [FrontendItemEffectType], null: true
      field :allowed_slots,    [String], null: true
      field :two_handed,       Boolean, null: true
      field :versatile,        Boolean, null: true
      field :using_two_handed, Boolean, null: true
    end

    class FrontendEquippedItemsType < Types::BaseObject
      field :right_hand,  FrontendEquipmentItemType, null: true
      field :left_hand,   FrontendEquipmentItemType, null: true
      field :quick_draw1, FrontendEquipmentItemType, null: true
      field :quick_draw2, FrontendEquipmentItemType, null: true
      field :slot1,       FrontendEquipmentItemType, null: true
      field :slot2,       FrontendEquipmentItemType, null: true
      field :slot3,       FrontendEquipmentItemType, null: true
      field :slot4,       FrontendEquipmentItemType, null: true
    end

    class FrontendCurrenciesType < Types::BaseObject
      field :tc, Integer, null: false
      field :tp, Integer, null: false
      field :to, Integer, null: false
    end

    # ─── Main CharacterType ───────────────────────────────────────────────────

    class CharacterType < Types::BaseObject
      description 'Frontend-facing Character type (flat, display-ready)'

      field :id,       ID,     null: false
      field :name,     String, null: false
      field :image_url, String, null: true

      field :classes, [CharacterClassType], null: false
      field :origin,  CharacterInfoType,    null: true
      field :deity,   CharacterInfoType,    null: true

      # Resources
      field :health,     Integer, null: false
      field :max_health, Integer, null: false
      field :mana,       Integer, null: false
      field :max_mana,   Integer, null: false

      # Attributes & Defenses
      field :attributes,  [FrontendAttributeType],  null: false
      field :resistances, [FrontendResistanceType], null: false
      field :defenses,    [FrontendDefenseType],    null: false

      # Combat (transient — managed client-side during combat)
      field :in_combat,          Boolean, null: true
      field :initiative_roll,    Integer, null: true
      field :is_my_turn,         Boolean, null: false
      field :turn_order,         Integer, null: false
      field :available_actions,  FrontendAvailableActionsType, null: false
      field :actions_list,       [FrontendCombatActionType],   null: false
      field :weapons,            [FrontendWeaponAttackType],   null: false

      # Skills & Abilities
      field :skills,    [FrontendSkillType],   null: false
      field :abilities, [FrontendAbilityType], null: true
      field :spells,    [FrontendSpellType],   null: true

      # Equipment
      field :equipped_items, FrontendEquippedItemsType,    null: false
      field :backpack,       [FrontendEquipmentItemType],  null: false
      field :currencies,     FrontendCurrenciesType,       null: false

      # Metadata
      field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
      field :version,    Integer, null: false

      # ─── Resolvers ───────────────────────────────────────────────────────────
      # object is a CharacterPresenter — all data flows through it.

      def id          = object.id
      def name        = object.name
      def image_url   = object.image_url
      def updated_at  = object.sheet.updated_at
      def version     = object.version

      def classes
        object.classes.map do |c|
          { name: c[:name], level: c[:level], tooltip: c[:description] }
        end
      end

      def origin
        o = object.origin
        return nil unless o
        { name: o[:name], tooltip: o[:description] }
      end

      def deity
        d = object.deity
        return nil unless d
        { name: d[:name], tooltip: d[:description] }
      end

      def health      = object.health
      def max_health  = object.max_health
      def mana        = object.mana
      def max_mana    = object.max_mana

      def attributes
        object.attributes.map do |key, data|
          {
            label: key,
            value: data["total"] || data[:total] || 10,
            modifier: data["modifier"] || data[:modifier] || 0,
            visible: true
          }
        end
      end


      def defenses
        defesa = object.defenses["defesa"] || {}
        return [] unless defesa.is_a?(Hash)
        [{ name: "Defesa", value: defesa["total"] || defesa[:total] || 0, tooltip: "" }]
      end

      def resistances
        all = object.defenses
        %w[fortitude reflexos vontade].map do |key|
          data = all[key] || {}
          { name: key.capitalize, value: data["total"] || data[:total] || 0, tooltip: "", visible: true }
        end
      end

      def skills
        object.skills.map do |key, data|
          {
            name: key,
            modifier: data["total"] || data[:total] || 0,
            trained: data["trained"] || data[:trained] || false,
            attribute: data["attribute"] || data[:attribute] || "",
            training_bonus: data["training_bonus"] || data[:training_bonus] || 0,
            other_bonuses: []
          }
        end
      end

      def abilities
        object.abilities.map do |a|
          {
            id: a[:ability_key] || a["ability_key"],
            name: a[:name] || a["name"] || "",
            description: a[:description] || a["description"] || "",
            type: (a[:type] || a["type"] || "").to_s,
            source: a[:source] || a["source"]
          }
        end
      end

      def spells
        (object.spells["known_spells"] || object.spells[:known_spells] || []).map do |s|
          {
            id: s[:spell_key] || s["spell_key"],
            name: s[:name] || s["name"] || "",
            type: s[:type] || s["type"] || "",
            circle: s[:circle] || s["circle"] || 1,
            school: s[:school] || s["school"] || "",
            execution: s[:execution] || s["execution"] || "",
            range: s[:range] || s["range"] || "",
            duration: s[:duration] || s["duration"] || "",
            description: s[:description] || s["description"] || "",
            enhancements: s[:enhancements] || s["enhancements"] || []
          }
        end
      end

      def weapons
        object.weapons.map do |w|
          {
            id: w[:id] || w["id"],
            name: w[:name] || w["name"] || "",
            damage: w[:damage] || w["damage"] || "1d4",
            damage_type: w[:damage_type] || w["damage_type"],
            attack_bonus: w[:attack_bonus] || w["attack_bonus"] || 0,
            attack_attribute: w[:attack_attribute] || w["attack_attribute"],
            crit_range: w[:crit_range] || w["crit_range"],
            range: w[:range] || w["range"],
            action_type: w[:action_type] || w["action_type"] || "standard",
            equipment_id: w[:equipment_id] || w["equipment_id"]
          }
        end
      end

      def actions_list = []

      def in_combat       = object.in_combat
      def initiative_roll = object.initiative_roll
      def is_my_turn      = object.is_my_turn
      def turn_order      = object.turn_order

      def available_actions
        data = object.available_actions
        return { "standard" => 1, "movement" => 1, "free" => 1, "full" => 1, "reaction" => 1 } if data.blank?
        data
      end

      def equipped_items
        data = object.equipped_items
        {
          right_hand:  format_item(data["main_hand"] || data["right_hand"]),
          left_hand:   format_item(data["off_hand"]  || data["left_hand"]),
          quick_draw1: format_item(data["quick_draw1"]),
          quick_draw2: format_item(data["quick_draw2"]),
          slot1:       format_item(data["slot1"]),
          slot2:       format_item(data["slot2"]),
          slot3:       format_item(data["slot3"]),
          slot4:       format_item(data["slot4"])
        }
      end

      def backpack
        object.inventory.map do |entry|
          item = entry[:item] || entry["item"]
          next nil unless item.is_a?(Hash)
          format_item(item)&.merge(quantity: entry[:quantity] || entry["quantity"] || 1)
        end.compact
      end

      def currencies
        data = object.currencies
        return { "tc" => 0, "tp" => 0, "to" => 0 } if data.blank?
        data
      end

      private

      def format_item(item)
        return nil unless item.is_a?(Hash)
        {
          id: item[:id] || item["id"] || "",
          name: item[:name] || item["name"] || "",
          description: item[:description] || item["description"],
          spaces: item[:weight] || item["weight"],
          price: item[:price] || item["price"],
          category: item[:category] || item["category"] || item[:item_type] || item["item_type"]
        }
      end
    end
  end
end
