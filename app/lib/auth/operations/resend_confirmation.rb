# frozen_string_literal: true

module Auth
  module Operations
    class ResendConfirmation < BaseOperation
      def call(email:)
        user = User.find_by(email: email.downcase)
        user.resend_confirmation_instructions if user && !user.confirmed?
        Success(true) # Always succeed silently
      end
    end
  end
end
