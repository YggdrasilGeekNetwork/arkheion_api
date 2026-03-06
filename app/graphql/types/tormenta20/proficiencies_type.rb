# frozen_string_literal: true

module Types
  module Tormenta20
    class ComputedProficienciesType < Types::BaseObject
      field :weapons, [String], null: false
      field :armors, [String], null: false
      field :shields, [String], null: false
      field :tools, [String], null: false
      field :exotic_weapons, [String], null: false
    end
  end
end
