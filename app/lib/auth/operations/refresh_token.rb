# frozen_string_literal: true

module Auth
  module Operations
    class RefreshToken < BaseOperation
      def call(refresh_token:)
        user = step validate_refresh_token(refresh_token)
        tokens = step generate_new_tokens(user)

        Success(user: user, tokens: tokens)
      end

      private

      def validate_refresh_token(token)
        user = JwtService.valid_refresh_token?(token)

        if user
          Success(user)
        else
          Failure[:invalid_token, 'Invalid or expired refresh token']
        end
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
