# frozen_string_literal: true

module Tormenta20
  module Pipeline
    class BasePipe
      class << self
        def call(context)
          new.call(context)
        end

        def to_proc
          ->(context) { call(context) }
        end
      end

      def call(context)
        raise NotImplementedError, "#{self.class}#call must be implemented"
      end

      private

      def modifier_for(value)
        (value - 10) / 2
      end

      def sum_bonuses(bonuses)
        return 0 if bonuses.blank?

        bonuses.sum { |b| b[:value] || b['value'] || 0 }
      end

      # Gem lookups

      def class_definition(class_key)
        return nil if class_key.blank?
        ::Tormenta20::Models::Classe.find_by(id: class_key)
      end

      def race_definition(race_key)
        return nil if race_key.blank?
        ::Tormenta20::Models::Raca.find_by(id: race_key)
      end

      def power_definition(power_key)
        return nil if power_key.blank?
        ::Tormenta20::Models::Poder.find_by(id: power_key)
      end

      def spell_definition(spell_key)
        return nil if spell_key.blank?
        ::Tormenta20::Models::Magia.find_by(id: spell_key)
      end

      def armor_definition(item_key)
        return nil if item_key.blank?
        ::Tormenta20::Models::Armadura.find_by(id: item_key)
      end

      def shield_definition(item_key)
        return nil if item_key.blank?
        ::Tormenta20::Models::Escudo.find_by(id: item_key)
      end

      def weapon_definition(item_key)
        return nil if item_key.blank?
        ::Tormenta20::Models::Arma.find_by(id: item_key)
      end

      def item_definition(item_key)
        return nil if item_key.blank?
        ::Tormenta20::Models::Item.find_by(id: item_key)
      end
    end
  end
end
