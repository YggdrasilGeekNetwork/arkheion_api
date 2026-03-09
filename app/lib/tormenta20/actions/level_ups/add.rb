# frozen_string_literal: true

module Tormenta20
  module Actions
    module LevelUps
      class Add < BaseAction
        def call(character_sheet_id:, params:, user:)
          Operations::LevelUps::Add.new.call(
            character_sheet_id: character_sheet_id,
            params: params,
            user: user
          )
        end
      end
    end
  end
end
