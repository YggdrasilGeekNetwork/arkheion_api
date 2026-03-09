# frozen_string_literal: true

module Tormenta20
  module Actions
    module Snapshots
      class Generate < BaseAction
        def call(character_sheet:, force: false)
          Operations::Snapshots::Generate.new.call(character_sheet: character_sheet, force: force)
        end
      end
    end
  end
end
