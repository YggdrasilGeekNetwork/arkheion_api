# frozen_string_literal: true

module Tormenta20
  module Schemas
    ProficienciesSchema = Dry::Schema.JSON do
      optional(:weapons).array(:string)
      optional(:armors).array(:string)
      optional(:shields).array(:string)
      optional(:tools).array(:string)
      optional(:exotic_weapons).array(:string)
    end
  end
end
