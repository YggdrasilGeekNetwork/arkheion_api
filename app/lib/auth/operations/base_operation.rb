# frozen_string_literal: true

module Auth
  module Operations
    class BaseOperation < Dry::Operation
      include Dry::Monads[:result]
    end
  end
end
