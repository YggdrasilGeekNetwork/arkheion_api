# frozen_string_literal: true

module Tormenta20
  module Actions
    module Characters
      class UpdateField < BaseAction
        def call(id:, user:, **kwargs)
          Operations::Characters::UpdateField.new.call(id: id, user: user, **kwargs)
        end
      end
    end
  end
end
