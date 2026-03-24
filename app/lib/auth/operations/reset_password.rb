# frozen_string_literal: true

module Auth
  module Operations
    class ResetPassword < BaseOperation
      def call(token:, password:, password_confirmation:)
        step validate_passwords(password, password_confirmation)
        user = step reset_password(token, password, password_confirmation)
        tokens = step generate_tokens(user)
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

      def reset_password(token, password, password_confirmation)
        user = User.reset_password_by_token(
          reset_password_token: token,
          password: password,
          password_confirmation: password_confirmation
        )

        if user.errors.any?
          Failure[:invalid_token, user.errors.full_messages.first]
        else
          Success(user)
        end
      end

      def generate_tokens(user)
        Success(
          access_token: JwtService.encode_access_token(user),
          refresh_token: JwtService.encode_refresh_token(user)
        )
      end
    end
  end
end
