# frozen_string_literal: true

module Types
  module Tormenta20
    module Inputs
      class AttributesInput < Types::BaseInputObject
        argument :forca, Integer, required: true
        argument :destreza, Integer, required: true
        argument :constituicao, Integer, required: true
        argument :inteligencia, Integer, required: true
        argument :sabedoria, Integer, required: true
        argument :carisma, Integer, required: true
      end

      class RaceChoicesInput < Types::BaseInputObject
        argument :attribute_bonuses, GraphQL::Types::JSON, required: false
        argument :chosen_abilities, [String], required: false
        argument :chosen_proficiencies, [String], required: false
        argument :chosen_skills, [String], required: false
        argument :variant_key, String, required: false
        argument :subrace_key, String, required: false
        argument :extra_data, GraphQL::Types::JSON, required: false
      end

      class OriginChoicesInput < Types::BaseInputObject
        argument :chosen_skills, [String], required: false
        argument :chosen_powers, [String], required: false
        argument :chosen_proficiencies, [String], required: false
        argument :chosen_items, [String], required: false
        argument :extra_data, GraphQL::Types::JSON, required: false
      end

      class CharacterSheetInput < Types::BaseInputObject
        argument :name, String, required: true
        argument :race_key, String, required: true
        argument :origin_key, String, required: true
        argument :deity_key, String, required: false
        argument :sheet_attributes, AttributesInput, required: true
        argument :race_choices, RaceChoicesInput, required: false
        argument :origin_choices, OriginChoicesInput, required: false
        argument :proficiencies, GraphQL::Types::JSON, required: false
        argument :metadata, GraphQL::Types::JSON, required: false
      end

      class CharacterSheetUpdateInput < Types::BaseInputObject
        argument :name, String, required: false
        argument :deity_key, String, required: false
        argument :sheet_attributes, AttributesInput, required: false
        argument :race_choices, RaceChoicesInput, required: false
        argument :origin_choices, OriginChoicesInput, required: false
        argument :proficiencies, GraphQL::Types::JSON, required: false
        argument :metadata, GraphQL::Types::JSON, required: false
      end
    end
  end
end
