# frozen_string_literal: true

module Types
  module Tormenta20
    class CharacterSummaryType < Types::BaseObject
      description 'Condensed character for listing'

      field :id,        ID,     null: false
      field :name,      String, null: false
      field :image_url, String, null: true
      field :classes,   [CharacterClassType], null: false
      field :level,     Integer, null: false

      def classes
        object.class_levels.map do |class_key, lvl|
          classe = ::Tormenta20::Models::Classe.find_by(id: class_key)
          { name: classe&.name || class_key.humanize, level: lvl }
        end
      end

      def level = object.current_level
    end
  end
end
