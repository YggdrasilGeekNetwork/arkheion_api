# frozen_string_literal: true

module Auth
  module Operations
    # Sets a password for the first time (OAuth-only users).
    # Does NOT require the current password.
    # For users who already have a password, use ChangePassword instead.
    class SetPassword < BaseOperation
      def call(user:, password:, password_confirmation:)
        step validate_passwords(password, password_confirmation)
        step update_password(user, password)
        step invalidate_tokens(user)
        tokens = step generate_new_tokens(user)
        Success(user: user, tokens: tokens)
      end

      private

      def validate_passwords(password, password_confirmation)
        if password.length < 8
          Failure[:validation_error, { password: ["must be at least 8 characters"] }]
        elsif password == password_confirmation
          Success(true)
        else
          Failure[:validation_error, { password_confirmation: ["does not match password"] }]
        end
      end

      def update_password(user, password)
        if user.update(password: password)
          Success(user)
        else
          Failure[:validation_error, user.errors.to_h]
        end
      end

      def invalidate_tokens(user)
        user.regenerate_jti!
        Success(user)
      end

      def generate_new_tokens(user)
        Success(
          access_token: JwtService.encode_access_token(user),
          refresh_token: JwtService.encode_refresh_token(user)
        )
      end
    end
  end
end
