# frozen_string_literal: true

module Auth
  module Operations
    class Logout < BaseOperation
      def call(user:)
        step invalidate_tokens(user)

        Success(logged_out: true)
      end

      private

      def invalidate_tokens(user)
        # Regenerate JTI to invalidate all existing tokens
        user.regenerate_jti!
        Success(user)
      rescue StandardError => e
        Failure[:internal_error, e.message]
      end
    end
  end
end
