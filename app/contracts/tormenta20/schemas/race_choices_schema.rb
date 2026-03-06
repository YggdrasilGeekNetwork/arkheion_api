# frozen_string_literal: true

module Tormenta20
  module Schemas
    RaceChoicesSchema = Dry::Schema.JSON do
      optional(:attribute_bonuses).hash do
        optional(:forca).filled(:integer)
        optional(:destreza).filled(:integer)
        optional(:constituicao).filled(:integer)
        optional(:inteligencia).filled(:integer)
        optional(:sabedoria).filled(:integer)
        optional(:carisma).filled(:integer)
      end

      optional(:chosen_abilities).array(:string)
      optional(:chosen_proficiencies).array(:string)
      optional(:chosen_skills).array(:string)
      optional(:variant_key).filled(:string)
      optional(:subrace_key).filled(:string)
      optional(:extra_data).hash
    end
  end
end
