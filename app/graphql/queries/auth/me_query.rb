# frozen_string_literal: true

module Queries
  module Auth
    class MeQuery < GraphQL::Schema::Resolver
      type Types::Auth::UserType, null: true

      def resolve
        context[:current_user]
      end
    end
  end
end
