# frozen_string_literal: true

module Tormenta20
  class BaseContract < Dry::Validation::Contract
    config.messages.backend = :i18n

    register_macro(:valid_attribute_value) do
      key.failure(:invalid_range) if key? && (value < 0 || value > 30)
    end

    register_macro(:valid_level) do
      key.failure(:invalid_level) if key? && (value < 1 || value > 20)
    end
  end
end
