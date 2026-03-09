# frozen_string_literal: true

module Tormenta20
  module Actions
    module Characters
      class LevelUp < BaseAction
        def call(id:, params:, user:)
          Operations::Characters::LevelUp.new.call(id: id, params: params, user: user)
        end
      end
    end
  end
end
