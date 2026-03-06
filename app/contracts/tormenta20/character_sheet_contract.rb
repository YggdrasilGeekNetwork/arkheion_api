# frozen_string_literal: true

module Tormenta20
  class CharacterSheetContract < BaseContract
    params do
      required(:name).filled(:string, min_size?: 1, max_size?: 100)
      required(:race_key).filled(:string)
      required(:origin_key).filled(:string)
      optional(:deity_key).maybe(:string)
      optional(:current_level).filled(:integer)

      required(:sheet_attributes).hash(Schemas::AttributesSchema)
      optional(:race_choices).hash(Schemas::RaceChoicesSchema)
      optional(:origin_choices).hash(Schemas::OriginChoicesSchema)
      optional(:proficiencies).hash(Schemas::ProficienciesSchema)
      optional(:metadata).hash
    end

    rule(:current_level).validate(:valid_level)

    rule(:sheet_attributes) do
      if key?
        total = value.values.sum
        key.failure('attribute points must sum to valid total') if total < 48 || total > 90
      end
    end
  end
end
