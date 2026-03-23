# frozen_string_literal: true

module Tormenta20
  module Presenters
    class CharacterPresenter
      attr_reader :sheet, :state, :snapshot

      def initialize(sheet, state: nil, snapshot: nil)
        @sheet    = sheet
        @state    = state    || sheet.character_state
        @snapshot = snapshot || ensure_fresh_snapshot
      end

      # Identity
      def id          = sheet.id
      def name        = sheet.name
      def image_url   = sheet.image_url
      def version     = sheet.character_version

      # Resources (current from state, max from snapshot)
      def health      = state&.current_pv || 0
      def max_health  = snapshot&.pv_max || 0
      def mana        = state&.current_pm || 0
      def max_mana    = snapshot&.pm_max || 0

      # Combat state
      def in_combat         = state&.in_combat || false
      def is_my_turn        = state&.is_my_turn || false
      def initiative_roll   = state&.initiative_roll_value
      def turn_order        = state&.turn_order || 0
      def available_actions = state&.available_actions_data || {}

      # Notes
      def notes = state&.notes || {}

      # Currency
      def currencies = state&.currency || {}

      # Classes (from level_ups + gem lookup for display name)
      def classes
        sheet.level_ups.group_by(&:class_key).map do |class_key, ups|
          classe = ::Tormenta20::Models::Classe.find_by(id: class_key)
          {
            key: class_key,
            name: classe&.name || class_key.humanize,
            level: ups.count
          }
        end
      end

      # Origin (from gem)
      def origin
        o = ::Tormenta20::Models::Origem.find_by(id: sheet.origin_key)
        { key: sheet.origin_key, name: o&.name || sheet.origin_key.humanize, description: o&.description }
      end

      # Deity (from gem, optional)
      def deity
        return nil unless sheet.deity_key
        d = ::Tormenta20::Models::Divindade.find_by(id: sheet.deity_key)
        { key: sheet.deity_key, name: d&.name || sheet.deity_key.humanize, description: d&.description }
      end

      # Race (from gem)
      def race
        r = ::Tormenta20::Models::Raca.find_by(id: sheet.race_key)
        { key: sheet.race_key, name: r&.name || sheet.race_key.humanize, size: r&.size, movement: r&.movement }
      end

      def size               = race[:size]
      def movement           = snapshot&.computed_resources&.dig("deslocamento", "total") || race[:movement] || 9

      def size_tooltip
        s = race[:size]
        return nil unless s
        case s.downcase
        when "minúsculo"        then "Tamanho Minúsculo: ocupa 0,75m, alcance 1,5m."
        when "pequeno"          then "Tamanho Pequeno: ocupa 1,5m, alcance 1,5m."
        when "médio", "medio"   then "Tamanho Médio: não confere bônus nem penalidades."
        when "grande"           then "Tamanho Grande: ocupa 3m, alcance 3m."
        when "enorme"           then "Tamanho Enorme: ocupa 4,5m, alcance 4,5m."
        when "colossal"         then "Tamanho Colossal: ocupa 6m, alcance 4,5m."
        else "Tamanho #{s}"
        end
      end

      def movement_tooltip
        desl = snapshot&.computed_resources&.dig("deslocamento")
        return nil unless desl

        base          = desl["base"] || 9
        armor_penalty = desl["armor_penalty"] || 0
        parts = ["#{base}m (base)"]
        parts << "−#{armor_penalty}m (armadura)" if armor_penalty > 0
        parts.join(" ")
      end
      def proficiency_bonus  = (sheet.level_ups.count + 1) / 2
      ATTR_DISPLAY = {
        "forca"        => "Força",
        "destreza"     => "Destreza",
        "constituicao" => "Constituição",
        "inteligencia" => "Inteligência",
        "sabedoria"    => "Sabedoria",
        "carisma"      => "Carisma"
      }.freeze

      def spell_save_dc          = snapshot&.computed_spells&.dig("save_dc", "total")
      def spellcasting_attribute = snapshot&.computed_spells&.dig("spellcasting_attribute")
      def spell_dc_notes
        (snapshot&.computed_spells&.dig("save_dc", "conditional_bonuses") || []).map do |b|
          "+#{b["value"]} #{b["condition"]} (#{b["label"]})"
        end
      end

      def spell_dc_tooltip
        save_dc = snapshot&.computed_spells&.dig("save_dc")
        return nil unless save_dc

        attr_display = ATTR_DISPLAY[spellcasting_attribute] || spellcasting_attribute&.humanize || "atributo"
        base     = save_dc["base"] || 10
        attr_mod = save_dc["attribute_modifier"] || 0
        other    = save_dc["other_bonuses"] || []

        parts = ["#{base} (base)"]
        parts << "#{attr_mod >= 0 ? '+' : ''}#{attr_mod} (#{attr_display})"
        other.each do |b|
          v = b["value"]
          parts << "#{v >= 0 ? '+' : ''}#{v} (#{b["label"]})"
        end

        parts.join(" ")
      end

      # Computed from snapshot
      def attributes    = snapshot&.computed_attributes || {}
      def defenses      = snapshot&.computed_defenses || {}
      def skills        = snapshot&.computed_skills || {}
      def proficiencies = snapshot&.computed_proficiencies || {}
      def senses        = snapshot&.computed_senses || []
      def abilities     = snapshot&.computed_abilities || []
      def spells        = snapshot&.computed_spells || {}

      # Weapons — resolved at presentation time from state + gem (not in snapshot, depends on equipped items)
      def weapons
        return [] unless state&.equipped_items.present?

        bab      = snapshot&.computed_combat&.dig("base_attack_bonus") || 0
        attrs    = snapshot&.computed_attributes || {}
        weapons  = []

        %w[main_hand off_hand].each do |slot|
          item_data = state.equipped_items[slot]
          next unless item_data&.dig("item_key")

          item_key = item_data["item_key"]
          arma = ::Tormenta20::Models::Arma.find_by(id: item_key)
          next unless arma

          attr_key = arma.ranged? ? "destreza" : "forca"
          attr_mod = attrs.dig(attr_key, "modifier") || attrs.dig(attr_key, :modifier) || 0

          weapons << {
            id: "#{slot}_#{item_key}",
            name: arma.name,
            damage: arma.damage || "1d4",
            damage_type: arma.damage_type,
            attack_bonus: bab + attr_mod,
            attack_attribute: attr_key,
            crit_range: arma.critical,
            range: arma.range,
            action_type: "standard",
            equipment_id: item_key
          }
        end

        weapons
      end

      # Equipment (resolve item_key → full data from gem)
      def equipped_items
        return {} unless state&.equipped_items.present?

        state.equipped_items.transform_values do |slot_data|
          next nil unless slot_data&.dig("item_key")
          resolve_item(slot_data["item_key"])
        end.compact
      end

      # Inventory list
      def inventory
        return [] unless state&.inventory.present?

        state.inventory.map do |entry|
          item_key = entry.is_a?(Hash) ? entry["item_key"] : entry.to_s
          item_data = resolve_item(item_key)
          { quantity: entry.is_a?(Hash) ? entry["quantity"] : 1, item: item_data }
        end
      end

      private

      def ensure_fresh_snapshot
        if sheet.snapshot_stale?
          result = Operations::Snapshots::Generate.new.call(character_sheet: sheet, force: true)
          result.success? ? sheet.snapshots.order(version: :desc).first : nil
        else
          sheet.latest_snapshot
        end
      end

      def resolve_item(item_key)
        arma = ::Tormenta20::Models::Arma.find_by(id: item_key)
        return arma.to_h.merge(item_type: "weapon") if arma

        armadura = ::Tormenta20::Models::Armadura.find_by(id: item_key)
        return armadura.to_h.merge(item_type: "armor") if armadura

        escudo = ::Tormenta20::Models::Escudo.find_by(id: item_key)
        return escudo.to_h.merge(item_type: "shield") if escudo

        item = ::Tormenta20::Models::Item.find_by(id: item_key)
        item&.to_h&.merge(item_type: "item")
      end
    end
  end
end
