# frozen_string_literal: true

module Tormenta20
  module Actions
    module Characters
      class Create < BaseAction
        def call(params:, user:)
          Operations::Characters::Create.new.call(params: params, user: user)
        end
      end
    end
  end
end
