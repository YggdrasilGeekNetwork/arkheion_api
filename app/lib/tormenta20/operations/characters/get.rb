# frozen_string_literal: true

module Tormenta20
  module Operations
    module Characters
      class Get < BaseOperation
        def call(id:, user:)
          sheet = step find_character_sheet(id, user: user)
          Success(character: Presenters::CharacterPresenter.new(sheet))
        end
      end
    end
  end
end
