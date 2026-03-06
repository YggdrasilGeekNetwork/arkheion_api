# frozen_string_literal: true

module Tormenta20
  module Schemas
    AttributesSchema = Dry::Schema.JSON do
      required(:forca).filled(:integer, gteq?: 0, lteq?: 30)
      required(:destreza).filled(:integer, gteq?: 0, lteq?: 30)
      required(:constituicao).filled(:integer, gteq?: 0, lteq?: 30)
      required(:inteligencia).filled(:integer, gteq?: 0, lteq?: 30)
      required(:sabedoria).filled(:integer, gteq?: 0, lteq?: 30)
      required(:carisma).filled(:integer, gteq?: 0, lteq?: 30)
    end
  end
end
