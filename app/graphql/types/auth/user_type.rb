# frozen_string_literal: true

module Types
  module Auth
    class UserType < Types::BaseObject
      field :id, ID, null: false
      field :email, String, null: false
      field :username, String, null: false
      field :display_name, String, null: true
      field :avatar_url, String, null: true
      field :confirmed, Boolean, null: false, method: :confirmed?
      field :active, Boolean, null: false
      field :has_password, Boolean, null: false
      field :oauth_providers, [String], null: false

      field :character_sheets, [Types::Tormenta20::CharacterSheetType], null: false
      field :character_sheets_count, Integer, null: false

      field :created_at, GraphQL::Types::ISO8601DateTime, null: false
      field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

      def character_sheets_count
        object.character_sheets.count
      end

      def has_password
        object.has_password?
      end

      def oauth_providers
        object.oauth_identities.pluck(:provider)
      end
    end
  end
end
