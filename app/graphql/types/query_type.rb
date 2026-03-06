# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    field :node, Types::NodeType, null: true, description: 'Fetches an object given its ID.' do
      argument :id, ID, required: true, description: 'ID of the object.'
    end

    def node(id:)
      context.schema.object_from_id(id, context)
    end

    field :nodes, [Types::NodeType, null: true], null: true, description: 'Fetches a list of objects given a list of IDs.' do
      argument :ids, [ID], required: true, description: 'IDs of the objects.'
    end

    def nodes(ids:)
      ids.map { |id| context.schema.object_from_id(id, context) }
    end

    # Auth queries
    field :me, resolver: Queries::Auth::MeQuery

    # Tormenta20 queries — frontend contract
    field :character, resolver: Queries::Tormenta20::CharacterQuery
    field :characters, resolver: Queries::Tormenta20::CharactersQuery

    # Tormenta20 rulebook — proxy to gem data (DM screen quick reference)
    field :rulebook, resolver: Queries::Tormenta20::RulebookQuery

    # Tormenta20 queries — internal / system
    field :character_sheet, resolver: Queries::Tormenta20::CharacterSheetQuery
    field :character_sheets, resolver: Queries::Tormenta20::CharacterSheetsQuery
    field :character_view, resolver: Queries::Tormenta20::CharacterViewQuery
  end
end
