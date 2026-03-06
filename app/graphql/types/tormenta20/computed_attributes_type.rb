# frozen_string_literal: true

module Types
  module Tormenta20
    class ComputedAttributesType < Types::BaseObject
      field :forca, AttributeValueType, null: false
      field :destreza, AttributeValueType, null: false
      field :constituicao, AttributeValueType, null: false
      field :inteligencia, AttributeValueType, null: false
      field :sabedoria, AttributeValueType, null: false
      field :carisma, AttributeValueType, null: false
    end
  end
end
