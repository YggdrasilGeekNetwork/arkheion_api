# frozen_string_literal: true

module Auth
  module Operations
    class Login < BaseOperation
      def call(email:, password:)
        user = step find_user(email)
        step authenticate(user, password)
        step check_active(user)
        tokens = step generate_tokens(user)

        Success(user: user, tokens: tokens)
      end

      private

      def find_user(email)
        user = User.find_by(email: email.downcase)

        if user
          Success(user)
        else
          Failure[:invalid_credentials, "Invalid email or password"]
        end
      end

      def authenticate(user, password)
        if user.oauth_only?
          return Failure[:no_password, 'Esta conta usa login pelo Google. Clique em "Entrar com Google" ou defina uma senha.']
        end

        if user.valid_password?(password)
          Success(user)
        else
          Failure[:invalid_credentials, "Invalid email or password"]
        end
      end

      def check_active(user)
        if user.active?
          Success(user)
        else
          Failure[:account_disabled, "Account is disabled"]
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
