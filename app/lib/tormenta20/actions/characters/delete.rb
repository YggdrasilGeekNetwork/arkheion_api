# frozen_string_literal: true

module Tormenta20
  module Actions
    module Characters
      class Delete < BaseAction
        def call(id:, user:)
          Operations::Characters::Delete.new.call(id: id, user: user)
        end
      end
    end
  end
end
