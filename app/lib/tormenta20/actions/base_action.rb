# frozen_string_literal: true

module Tormenta20
  module Actions
    class BaseAction
      include Dry::Monads[:result, :do]

      class << self
        def call(...)
          new.call(...)
        end
      end

      private

      def authorize!(user:, resource:, action:)
        # Policy check placeholder
        # Would integrate with Pundit or similar
        Success(true)
      end

      def with_transaction(&block)
        result = nil
        ActiveRecord::Base.transaction do
          result = block.call
          raise ActiveRecord::Rollback if result.failure?
        end
        result
      end

      def broadcast(event_name, payload)
        # Event broadcasting placeholder
        # Would integrate with ActionCable or similar
        Rails.logger.info("[Event] #{event_name}: #{payload.inspect}")
      end
    end
  end
end
