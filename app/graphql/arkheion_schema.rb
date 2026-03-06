# frozen_string_literal: true

class ArkheionSchema < GraphQL::Schema
  mutation(Types::MutationType)
  query(Types::QueryType)

  use GraphQL::Dataloader

  def self.resolve_type(abstract_type, obj, ctx)
    raise GraphQL::RequiredImplementationMissingError
  end

  def self.object_from_id(id, query_ctx)
    nil
  end

  def self.id_from_object(object, type_definition, query_ctx)
    GraphQL::Schema::UniqueWithinType.id_from_object(object, type_definition, query_ctx)
  end
end
