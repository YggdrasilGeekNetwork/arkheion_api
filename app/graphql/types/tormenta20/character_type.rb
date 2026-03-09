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

    class FrontendSenseType < Types::BaseObject
      field :name,    String, null: false
      field :value,   String, null: false
      field :tooltip, String, null: true
    end

    class FrontendProficiencyType < Types::BaseObject
      field :name,     String, null: false
      field :tooltip,  String, null: true
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

    # ─── Class abilities for level-up ─────────────────────────────────────────

    class AvailablePowerType < Types::BaseObject
      field :id,          ID,      null: false
      field :name,        String,  null: false
      field :description, String,  null: false
      field :type,        String,  null: false
      field :cost,        FrontendActionCostType, null: true
      field :source,      String,  null: true
    end

    class ClassLevelAbilitiesType < Types::BaseObject
      field :power_choices,      Integer,             null: false
      field :fixed_abilities,    [String],            null: false
      field :selectable_powers,  [AvailablePowerType], null: false
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
      field :size,                   String,  null: true
      field :movement,               Integer, null: true
      field :proficiency_bonus,      Integer, null: false
      field :spell_save_dc,          Integer,  null: true
      field :spellcasting_attribute, String,   null: true
      field :spell_dc_notes,         [String], null: false
      field :spell_dc_tooltip,       String,   null: true

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

      # Senses & Proficiencies
      field :senses,        [FrontendSenseType],        null: false
      field :proficiencies, [FrontendProficiencyType],  null: false

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
      def size              = object.size
      def movement          = object.movement
      def proficiency_bonus      = object.proficiency_bonus
      def spell_save_dc          = object.spell_save_dc
      def spellcasting_attribute = object.spellcasting_attribute
      def spell_dc_notes         = object.spell_dc_notes
      def spell_dc_tooltip       = object.spell_dc_tooltip

      ATTRIBUTE_ORDER = %w[forca destreza constituicao sabedoria inteligencia carisma].freeze

      def attributes
        attrs = object.attributes
        ATTRIBUTE_ORDER.filter_map do |key|
          data = attrs[key] || attrs[key.to_sym]
          next unless data
          {
            label: key,
            value: data["total"] || data[:total] || 10,
            modifier: data["modifier"] || data[:modifier] || 0,
            visible: true
          }
        end
      end


      def senses
        object.senses.map do |s|
          { name: s["name"] || s[:name], value: s["value"] || s[:value], tooltip: s["tooltip"] || s[:tooltip] }
        end
      end

      def proficiencies
        format_proficiencies(object.proficiencies)
      end

      def defenses
        defesa = object.defenses["defesa"] || {}
        total = defesa["total"] || defesa[:total] || 10
        [{ name: "Defesa", value: total, tooltip: format_defense_tooltip(defesa) }]
      end

      def resistances
        all = object.defenses
        %w[fortitude reflexos vontade].map do |key|
          data = all[key] || {}
          { name: key.capitalize, value: data["total"] || data[:total] || 0, tooltip: format_save_tooltip(data), visible: true }
        end
      end

      def skills
        object.skills.map do |key, data|
          {
            name: key,
            modifier: data["total"] || data[:total] || 0,
            trained: data["trained"] || data[:trained] || false,
            attribute: data["attribute"] || data[:attribute] || "",
            level_bonus: data["level_bonus"] || data[:level_bonus] || 0,
            training_bonus: data["training_bonus"] || data[:training_bonus] || 0,
            other_bonuses: (data["other_bonuses"] || data[:other_bonuses] || []).map do |b|
              { label: b["label"] || b[:label] || "", value: b["value"] || b[:value] || 0 }
            end,
            tooltip: format_skill_tooltip(data),
            visible_in_combat: SKILLS_VISIBLE_IN_COMBAT.include?(key),
            visible_in_summary: SKILLS_VISIBLE_IN_SUMMARY.include?(key)
          }
        end
      end

      def abilities
        object.abilities.map do |a|
          raw_costs = a["costs"] || a[:costs] || []
          {
            id: a[:ability_key] || a["ability_key"],
            name: a[:name] || a["name"] || "",
            description: a[:description] || a["description"] || "",
            type: (a[:type] || a["type"] || "").to_s,
            source: a[:source] || a["source"],
            action_type: nil,
            cost: extract_ability_cost(raw_costs),
            uses_per_day: nil,
            is_favorite: nil,
            favorite_order: nil
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
            execution_details: s[:execution_details] || s["execution_details"],
            range: s[:range] || s["range"] || "",
            target: format_spell_target(s),
            area_effect: s[:area_effect] || s["area_effect"],
            area_effect_details: s[:area_effect_details] || s["area_effect_details"],
            counterspell: s[:counterspell] || s["counterspell"],
            duration: s[:duration] || s["duration"] || "",
            duration_details: s[:duration_details] || s["duration_details"],
            resistance: format_spell_resistance(s),
            extra_costs: format_spell_extra_costs(s),
            description: s[:description] || s["description"] || "",
            enhancements: format_spell_enhancements(s[:enhancements] || s["enhancements"] || []),
            effects: format_spell_effects(s[:effects] || s["effects"] || []),
            is_favorite: nil,
            favorite_order: nil
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
            crit_multiplier: w[:crit_multiplier] || w["crit_multiplier"],
            range: w[:range] || w["range"],
            action_type: w[:action_type] || w["action_type"] || "standard",
            is_favorite: nil,
            favorite_order: nil,
            equipment_id: w[:equipment_id] || w["equipment_id"]
          }
        end
      end

      def actions_list
        items = []
        items.concat(weapon_actions)
        items.concat(active_ability_actions)
        items.concat(spell_actions)
        items
      end

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

      SKILLS_VISIBLE_IN_COMBAT = %w[
        iniciativa luta pontaria acrobacia atletismo
        furtividade percepcao intimidacao
      ].freeze

      SKILLS_VISIBLE_IN_SUMMARY = %w[
        iniciativa luta pontaria acrobacia atletismo furtividade
        percepcao diplomacia enganacao intimidacao misticismo
      ].freeze

      ATTR_ABBR = {
        "forca"        => "FOR",
        "destreza"     => "DES",
        "constituicao" => "CON",
        "inteligencia" => "INT",
        "sabedoria"    => "SAB",
        "carisma"      => "CAR"
      }.freeze

      SAVE_ATTR_LABEL = {
        "constituicao" => "CON",
        "destreza"     => "DES",
        "sabedoria"    => "SAB"
      }.freeze

      def format_skill_tooltip(data)
        parts = []

        attr = data["attribute"] || data[:attribute]
        attr_mod = data["attribute_modifier"] || data[:attribute_modifier] || 0
        attr_label = ATTR_ABBR[attr] || attr&.upcase || ""
        parts << "#{attr_label} (#{sign(attr_mod)})" if attr_label.present?

        ranks = data["level_bonus"] || data[:level_bonus] || 0
        parts << "Nível (#{sign(ranks)})" if ranks != 0

        training = data["training_bonus"] || data[:training_bonus] || 0
        parts << "Treinado (#{sign(training)})" if training != 0

        (data["other_bonuses"] || data[:other_bonuses] || []).each do |b|
          val = b["value"] || b[:value] || 0
          lbl = b["label"] || b[:label] || ""
          parts << "#{lbl} (#{sign(val)})" if val != 0
        end

        parts.join(" + ")
      end

      PROFICIENCY_LABELS = {
        # weapons
        "simples"           => "Armas Simples",
        "marciais"          => "Armas Marciais",
        "armas_simples"     => "Armas Simples",
        "armas_marciais"    => "Armas Marciais",
        # armors
        "leves"             => "Armaduras Leves",
        "médias"            => "Armaduras Médias",
        "pesadas"           => "Armaduras Pesadas",
        "armaduras_leves"   => "Armaduras Leves",
        "armaduras_medias"  => "Armaduras Médias",
        "armaduras_pesadas" => "Armaduras Pesadas",
        # shields / tools
        "escudos"           => "Escudos"
      }.freeze

      def format_proficiencies(data)
        return [] if data.blank?

        entries = []

        (data["weapons"] || data[:weapons] || []).each do |k|
          entries << { name: PROFICIENCY_LABELS[k] || k.humanize, tooltip: nil }
        end
        (data["armors"] || data[:armors] || []).each do |k|
          entries << { name: PROFICIENCY_LABELS[k] || k.humanize, tooltip: nil }
        end
        (data["shields"] || data[:shields] || []).each do |k|
          entries << { name: PROFICIENCY_LABELS[k] || k.humanize, tooltip: nil }
        end
        (data["tools"] || data[:tools] || []).each do |k|
          entries << { name: k.humanize, tooltip: nil }
        end
        (data["exotic_weapons"] || data[:exotic_weapons] || []).each do |k|
          entries << { name: k.humanize, tooltip: "Arma exótica" }
        end

        entries
      end

      def format_defense_tooltip(data)
        parts = ["Base 10"]

        dex = data["dexterity_bonus"] || data[:dexterity_bonus] || 0
        parts << "DES (#{sign(dex)})" if dex != 0

        armor = data["armor_bonus"] || data[:armor_bonus] || 0
        parts << "Armadura (#{sign(armor)})" if armor != 0

        shield = data["shield_bonus"] || data[:shield_bonus] || 0
        parts << "Escudo (#{sign(shield)})" if shield != 0

        (data["other_bonuses"] || data[:other_bonuses] || []).each do |b|
          val = b["value"] || b[:value] || 0
          lbl = b["label"] || b[:label] || ""
          parts << "#{lbl} (#{sign(val)})" if val != 0
        end

        parts.join(" + ")
      end

      def format_save_tooltip(data)
        parts = []

        attr = data["attribute"] || data[:attribute]
        attr_bonus = data["attribute_bonus"] || data[:attribute_bonus] || 0
        attr_label = SAVE_ATTR_LABEL[attr] || attr&.upcase || ""
        parts << "#{attr_label} (#{sign(attr_bonus)})" if attr_label.present?

        (data["other_bonuses"] || data[:other_bonuses] || []).each do |b|
          val = b["value"] || b[:value] || 0
          lbl = b["label"] || b[:label] || ""
          parts << "#{lbl} (#{sign(val)})" if val != 0
        end

        parts.join(" + ")
      end

      def sign(val)
        val >= 0 ? "+#{val}" : val.to_s
      end

      def weapon_actions
        object.weapons.map do |w|
          bonus = w[:attack_bonus] || w["attack_bonus"] || 0
          dmg   = w[:damage] || w["damage"] || "1d4"
          sign  = bonus >= 0 ? "+#{bonus}" : bonus.to_s
          {
            id:     "weapon_#{w[:id] || w['id']}",
            name:   w[:name] || w["name"] || "",
            type:   "attack",
            cost:   nil,
            effect: "Ataque #{sign} — Dano #{dmg}",
            modal:  false
          }
        end
      end

      def active_ability_actions
        object.abilities.filter_map do |a|
          effects = a[:effects] || a["effects"] || {}
          next unless active_effects?(effects)

          {
            id:     "ability_#{a[:ability_key] || a['ability_key']}",
            name:   a[:name] || a["name"] || "",
            type:   (a[:type] || a["type"] || "ability").to_s,
            cost:   extract_cost(effects),
            effect: a[:description] || a["description"] || "",
            modal:  false
          }
        end
      end

      def spell_actions
        (object.spells["known_spells"] || object.spells[:known_spells] || []).map do |s|
          exec    = s[:execution] || s["execution"] || ""
          range   = s[:range] || s["range"] || ""
          duration = s[:duration] || s["duration"] || ""
          tooltip = [exec, range, duration].reject(&:blank?).join(" — ")

          {
            id:      "spell_#{s[:spell_key] || s['spell_key']}",
            name:    s[:name] || s["name"] || "",
            type:    "spell",
            cost:    nil,
            effect:  s[:description] || s["description"] || "",
            tooltip: tooltip.presence
          }
        end
      end

      def active_effects?(effects)
        return false unless effects.is_a?(Hash)
        effects["type"].to_s == "active" ||
          effects[:type].to_s == "active" ||
          effects.key?("cost") ||
          effects.key?(:cost)
      end

      # Converts a `costs` array (from gem JSON) into { pm:, pv: }
      # Example: [{ "value" => 2, "type" => "PM" }] → { pm: 2 }
      def extract_ability_cost(costs)
        return nil unless costs.is_a?(Array) && costs.any?

        pm = costs.find { |c| (c["type"] || c[:type]).to_s.upcase == "PM" }&.then { |c| c["value"] || c[:value] }
        pv = costs.find { |c| (c["type"] || c[:type]).to_s.upcase == "PV" }&.then { |c| c["value"] || c[:value] }

        return nil if pm.nil? && pv.nil?

        { pm: pm.is_a?(Integer) ? pm : nil, pv: pv.is_a?(Integer) ? pv : nil }
      end

      def extract_cost(effects)
        return nil unless effects.is_a?(Hash)
        cost_str = (effects["cost"] || effects[:cost]).to_s
        return nil if cost_str.blank?

        if cost_str =~ /(\d+)\s*PM/i
          { pm: $1.to_i }
        elsif cost_str =~ /(\d+)\s*PV/i
          { pv: $1.to_i }
        end
      end

      def format_spell_target(s)
        type = s[:target_type] || s["target_type"]
        return nil unless type.present?

        {
          type: type,
          amount: s[:target_amount] || s["target_amount"],
          up_to: s[:target_up_to] || s["target_up_to"]
        }
      end

      def format_spell_resistance(s)
        skill  = s[:resistence_skill]  || s["resistence_skill"]
        effect = s[:resistence_effect] || s["resistence_effect"]
        return nil unless skill.present? || effect.present?

        [skill, effect].compact.join(" — ")
      end

      def format_spell_extra_costs(s)
        parts = []
        mat = s[:extra_costs_material_component] || s["extra_costs_material_component"]
        cost = s[:extra_costs_material_cost] || s["extra_costs_material_cost"]
        debuff = s[:extra_costs_pm_debuff] || s["extra_costs_pm_debuff"]
        sacrifice = s[:extra_costs_pm_sacrifice] || s["extra_costs_pm_sacrifice"]

        parts << "Componente material: #{mat}#{cost.present? ? " (#{cost})" : ""}" if mat.present?
        parts << "PM (debuff): #{debuff}" if debuff.present?
        parts << "PM (sacrifício): #{sacrifice}" if sacrifice.present?
        parts.empty? ? nil : parts.join("; ")
      end

      def format_spell_effects(raw_effects)
        return [] unless raw_effects.is_a?(Array)

        raw_effects.map do |e|
          next nil unless e.is_a?(Hash)
          {
            type: e["type"] || e[:type] || "",
            attribute: e["attribute"] || e[:attribute],
            amount: (e["amount"] || e[:amount])&.to_s,
            resistance_requirement: e["resistance_requirement"] || e[:resistance_requirement],
            extra_requirements: e["extra_requirements"] || e[:extra_requirements]
          }
        end.compact
      end

      def format_spell_enhancements(raw_enhancements)
        return [] unless raw_enhancements.is_a?(Array)

        raw_enhancements.map do |e|
          next nil unless e.is_a?(Hash)
          extra = e["extra_details"] || e[:extra_details]
          {
            cost: (e["cost"] || e[:cost]).to_i,
            type: (e["type"] || e[:type] || "").to_s,
            description: (e["description"] || e[:description] || "").to_s,
            extra_details: extra.is_a?(Hash) ? {
              execution: extra["execution"] || extra[:execution],
              duration: extra["duration"] || extra[:duration],
              circle: extra["circle"] || extra[:circle],
              effects: format_spell_effects(extra["effects"] || extra[:effects] || [])
            } : nil
          }
        end.compact
      end

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
