# frozen_string_literal: true

module Tormenta20
  module Actions
    module CharacterSheets
      class Update < BaseAction
        def call(id:, params:, user:)
          Operations::CharacterSheets::Update.new.call(id: id, params: params, user: user)
        end
      end
    end
  end
end
