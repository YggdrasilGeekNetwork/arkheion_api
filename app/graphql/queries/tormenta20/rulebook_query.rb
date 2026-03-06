# frozen_string_literal: true

module Queries
  module Tormenta20
    class RulebookQuery < GraphQL::Schema::Resolver
      type Types::Tormenta20::RulebookType, null: false

      def resolve
        # Returns a sentinel object; all resolution happens in RulebookType methods
        {}
      end
    end
  end
end
