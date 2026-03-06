# frozen_string_literal: true

module Tormenta20
  module Operations
    module Characters
      class Delete < BaseOperation
        def call(id:, user:)
          sheet = step find_character_sheet(id, user: user)
          sheet.destroy!
          Success(true)
        end
      end
    end
  end
end
