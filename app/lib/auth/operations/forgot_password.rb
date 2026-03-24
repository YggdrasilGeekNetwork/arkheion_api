# frozen_string_literal: true

module Auth
  module Operations
    class ForgotPassword < BaseOperation
      def call(email:)
        user = User.find_by(email: email.downcase)
        # Always return success even if not found (security — don't leak emails)
        user&.send_reset_password_instructions
        Success(true)
      end
    end
  end
end
