# frozen_string_literal: true

module Tormenta20
  class CharacterSheet < ApplicationRecord
    self.table_name = "tormenta20_character_sheets"

    belongs_to :user
    belongs_to :campaign, optional: true

    has_many :level_ups,
             class_name: "Tormenta20::LevelUp",
             foreign_key: :character_sheet_id,
             dependent: :destroy,
             inverse_of: :character_sheet

    has_many :snapshots,
             class_name: "Tormenta20::CharacterSnapshot",
             foreign_key: :character_sheet_id,
             dependent: :destroy,
             inverse_of: :character_sheet

    has_one :character_state,
            class_name: "Tormenta20::CharacterState",
            foreign_key: :character_sheet_id,
            dependent: :destroy,
            inverse_of: :character_sheet

    validates :name, presence: true, length: { maximum: 100 }
    validates :race_key, presence: true
    validates :origin_key, presence: true

    validate :validate_sheet_attributes_schema
    validate :validate_race_choices_schema
    validate :validate_origin_choices_schema
    validate :validate_proficiencies_schema

    after_create :create_initial_state

    # Calculated from level_ups count
    def current_level
      level_ups.count
    end

    def latest_snapshot
      snapshots.order(version: :desc).first
    end

    def snapshot_stale?
      return true if latest_snapshot.nil?

      latest_snapshot.checksum != compute_checksum
    end

    def compute_checksum
      Digest::SHA256.hexdigest(
        [
          attributes_for_checksum,
          level_ups.order(:level).map(&:attributes_for_checksum)
        ].to_json
      )
    end

    def attributes_for_checksum
      {
        sheet_attributes: self.attributes.slice("sheet_attributes", "race_choices", "origin_choices", "proficiencies"),
        race_key: race_key,
        origin_key: origin_key,
        deity_key: deity_key
      }
    end

    def class_levels
      level_ups.group(:class_key).count
    end

    def primary_class
      level_ups.group(:class_key).count.max_by { |_, count| count }&.first
    end

    def can_level_up?
      current_level < 20
    end

    private

    def create_initial_state
      create_character_state! unless character_state
    end

    def validate_sheet_attributes_schema
      return if sheet_attributes.blank?

      result = Schemas::AttributesSchema.call(sheet_attributes)
      return if result.success?

      result.errors.to_h.each do |field, messages|
        errors.add(:sheet_attributes, "#{field}: #{messages.join(", ")}")
      end
    end

    def validate_race_choices_schema
      return if race_choices.blank?

      result = Schemas::RaceChoicesSchema.call(race_choices)
      return if result.success?

      result.errors.to_h.each do |field, messages|
        errors.add(:race_choices, "#{field}: #{messages.join(', ')}")
      end
    end

    def validate_origin_choices_schema
      return if origin_choices.blank?

      result = Schemas::OriginChoicesSchema.call(origin_choices)
      return if result.success?

      result.errors.to_h.each do |field, messages|
        errors.add(:origin_choices, "#{field}: #{messages.join(', ')}")
      end
    end

    def validate_proficiencies_schema
      return if proficiencies.blank?

      result = Schemas::ProficienciesSchema.call(proficiencies)
      return if result.success?

      result.errors.to_h.each do |field, messages|
        errors.add(:proficiencies, "#{field}: #{messages.join(', ')}")
      end
    end
  end
end
