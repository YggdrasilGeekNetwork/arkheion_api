# frozen_string_literal: true

module Types
  module Auth
    class AuthPayloadType < Types::BaseObject
      field :user, Types::Auth::UserType, null: false
      field :access_token, String, null: false
      field :refresh_token, String, null: false
    end
  end
end
