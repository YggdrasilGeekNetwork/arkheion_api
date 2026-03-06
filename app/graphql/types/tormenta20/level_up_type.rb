# frozen_string_literal: true

module Types
  module Tormenta20
    class LevelUpType < Types::BaseObject
      field :id, ID, null: false
      field :level, Integer, null: false
      field :class_key, String, null: false

      field :class_choices, GraphQL::Types::JSON, null: false
      field :skill_points, GraphQL::Types::JSON, null: false
      field :abilities_chosen, GraphQL::Types::JSON, null: false
      field :powers_chosen, GraphQL::Types::JSON, null: false
      field :spells_chosen, GraphQL::Types::JSON, null: false
      field :metadata, GraphQL::Types::JSON, null: true

      field :first_level_in_class, Boolean, null: false, method: :first_level_in_class?
      field :multiclass, Boolean, null: false, method: :multiclass?

      field :created_at, GraphQL::Types::ISO8601DateTime, null: false
      field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    end
  end
end
