# frozen_string_literal: true

module Tormenta20
  module Schemas
    OriginChoicesSchema = Dry::Schema.JSON do
      optional(:chosen_skills).array(:string)
      optional(:chosen_powers).array(:string)
      optional(:chosen_proficiencies).array(:string)
      optional(:chosen_items).array(:string)
      optional(:extra_data).hash
    end
  end
end
