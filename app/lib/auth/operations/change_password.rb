# frozen_string_literal: true

module Auth
  module Operations
    class ChangePassword < BaseOperation
      def call(user:, current_password:, new_password:, new_password_confirmation:)
        step verify_current_password(user, current_password)
        step validate_new_passwords(new_password, new_password_confirmation)
        step update_password(user, new_password)
        step invalidate_tokens(user)
        tokens = step generate_new_tokens(user)

        Success(user: user, tokens: tokens)
      end

      private

      def verify_current_password(user, password)
        if user.valid_password?(password)
          Success(user)
        else
          Failure[:invalid_credentials, "Current password is incorrect"]
        end
      end

      def validate_new_passwords(password, confirmation)
        if password == confirmation
          Success(true)
        else
          Failure[:validation_error, { new_password_confirmation: ["does not match"] }]
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
