# frozen_string_literal: true

module Types
  module Tormenta20
    class CharacterSheetType < Types::BaseObject
      field :id, ID, null: false
      field :name, String, null: false
      field :race_key, String, null: false
      field :origin_key, String, null: false
      field :deity_key, String, null: true
      field :current_level, Integer, null: false

      field :sheet_attributes, GraphQL::Types::JSON, null: false
      field :race_choices, GraphQL::Types::JSON, null: false
      field :origin_choices, GraphQL::Types::JSON, null: false
      field :proficiencies, GraphQL::Types::JSON, null: false
      field :metadata, GraphQL::Types::JSON, null: true

      field :level_ups, [LevelUpType], null: false
      field :latest_snapshot, CharacterSnapshotType, null: true
      field :character_state, CharacterStateType, null: true

      field :class_levels, GraphQL::Types::JSON, null: false
      field :primary_class, String, null: true
      field :snapshot_stale, Boolean, null: false, method: :snapshot_stale?

      field :created_at, GraphQL::Types::ISO8601DateTime, null: false
      field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    end
  end
end
