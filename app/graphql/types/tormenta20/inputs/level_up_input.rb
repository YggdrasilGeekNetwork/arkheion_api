# frozen_string_literal: true

module Types
  module Tormenta20
    module Inputs
      class LevelUpInput < Types::BaseInputObject
        argument :class_key, String, required: true
        argument :class_choices, GraphQL::Types::JSON, required: false
        argument :skill_points, GraphQL::Types::JSON, required: false
        argument :abilities_chosen, GraphQL::Types::JSON, required: false
        argument :powers_chosen, GraphQL::Types::JSON, required: false
        argument :spells_chosen, GraphQL::Types::JSON, required: false
        argument :metadata, GraphQL::Types::JSON, required: false
      end

      class LevelUpUpdateInput < Types::BaseInputObject
        argument :class_choices, GraphQL::Types::JSON, required: false
        argument :skill_points, GraphQL::Types::JSON, required: false
        argument :abilities_chosen, GraphQL::Types::JSON, required: false
        argument :powers_chosen, GraphQL::Types::JSON, required: false
        argument :spells_chosen, GraphQL::Types::JSON, required: false
        argument :metadata, GraphQL::Types::JSON, required: false
      end
    end
  end
end
