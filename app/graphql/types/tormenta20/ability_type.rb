# frozen_string_literal: true

module Types
  module Tormenta20
    class AbilityType < Types::BaseObject
      field :ability_key, String, null: false
      field :name, String, null: false
      field :source, String, null: false
      field :type, String, null: true
      field :description, String, null: true
      field :uses_per_day, Integer, null: true
      field :action_type, String, null: true
    end
  end
end
