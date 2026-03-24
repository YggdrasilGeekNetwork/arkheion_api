# frozen_string_literal: true

module Mutations
  module Auth
    class ResendConfirmation < GraphQL::Schema::Mutation
      argument :email, String, required: true

      field :success, Boolean, null: false
      field :errors, [String], null: true

      def resolve(email:)
        ::Auth::Operations::ResendConfirmation.new.call(email: email)
        { success: true, errors: nil }
      end
    end
  end
end
