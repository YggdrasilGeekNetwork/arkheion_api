# frozen_string_literal: true

module Tormenta20
  class LevelUp < ApplicationRecord
    self.table_name = "tormenta20_level_ups"

    belongs_to :character_sheet,
               class_name: "Tormenta20::CharacterSheet",
               inverse_of: :level_ups

    validates :level, presence: true,
                      uniqueness: { scope: :character_sheet_id },
                      numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 20 }
    validates :class_key, presence: true

    validate :validate_class_choices_schema
    validate :validate_skill_points_schema
    validate :validate_abilities_chosen_schema
    validate :validate_powers_chosen_schema
    validate :validate_spells_chosen_schema
    validate :level_sequence

    def attributes_for_checksum
      {
        level: level,
        class_key: class_key,
        class_choices: class_choices,
        skill_points: skill_points,
        abilities_chosen: abilities_chosen,
        powers_chosen: powers_chosen,
        spells_chosen: spells_chosen
      }
    end

    def first_level_in_class?
      character_sheet.level_ups
                     .where(class_key: class_key)
                     .where("level < ?", level)
                     .none?
    end

    def multiclass?
      level > 1 && first_level_in_class?
    end

    private

    def level_sequence
      return if level == 1

      previous_level = character_sheet.level_ups.find_by(level: level - 1)
      errors.add(:level, "previous level must exist") unless previous_level
    end

    def validate_class_choices_schema
      return if class_choices.blank?

      result = Schemas::ClassChoicesSchema.call(class_choices)
      return if result.success?

      result.errors.to_h.each do |field, messages|
        errors.add(:class_choices, "#{field}: #{messages.join(', ')}")
      end
    end

    def validate_skill_points_schema
      return if skill_points.blank?

      result = Schemas::SkillPointsSchema.call(skill_points)
      return if result.success?

      result.errors.to_h.each do |field, messages|
        errors.add(:skill_points, "#{field}: #{messages.join(', ')}")
      end
    end

    def validate_abilities_chosen_schema
      return if abilities_chosen.blank?

      result = Schemas::AbilitiesChosenSchema.call(abilities_chosen)
      return if result.success?

      result.errors.to_h.each do |field, messages|
        errors.add(:abilities_chosen, "#{field}: #{messages.join(', ')}")
      end
    end

    def validate_powers_chosen_schema
      return if powers_chosen.blank?

      result = Schemas::PowersChosenSchema.call(powers_chosen)
      return if result.success?

      result.errors.to_h.each do |field, messages|
        errors.add(:powers_chosen, "#{field}: #{messages.join(', ')}")
      end
    end

    def validate_spells_chosen_schema
      return if spells_chosen.blank?

      result = Schemas::SpellsChosenSchema.call(spells_chosen)
      return if result.success?

      result.errors.to_h.each do |field, messages|
        errors.add(:spells_chosen, "#{field}: #{messages.join(', ')}")
      end
    end
  end
end
