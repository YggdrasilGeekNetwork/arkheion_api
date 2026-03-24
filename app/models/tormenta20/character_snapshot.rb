# frozen_string_literal: true

module Tormenta20
  class CharacterSnapshot < ApplicationRecord
    self.table_name = "tormenta20_character_snapshots"

    belongs_to :character_sheet,
               class_name: "Tormenta20::CharacterSheet",
               inverse_of: :snapshots

    validates :version, presence: true,
                        uniqueness: { scope: :character_sheet_id },
                        numericality: { only_integer: true, greater_than: 0 }
    validates :checksum, presence: true
    validates :computed_at, presence: true

    before_validation :set_version, on: :create
    before_validation :set_computed_at, on: :create

    scope :latest, -> { order(version: :desc).limit(1) }
    scope :for_checksum, ->(checksum) { where(checksum: checksum) }

    def stale?
      checksum != character_sheet.compute_checksum
    end

    def pv_max
      computed_resources.dig("pv", "max") || 0
    end

    def pm_max
      computed_resources.dig("pm", "max") || 0
    end

    def attribute_modifier(attribute_key)
      computed_attributes.dig(attribute_key.to_s, "modifier") || 0
    end

    def skill_total(skill_key)
      computed_skills.dig(skill_key.to_s, "total") || 0
    end

    def defense_total(defense_key)
      computed_defenses.dig(defense_key.to_s, "total") || 0
    end

    private

    def set_version
      self.version ||= (character_sheet.snapshots.maximum(:version) || 0) + 1
    end

    def set_computed_at
      self.computed_at ||= Time.current
    end
  end
end
