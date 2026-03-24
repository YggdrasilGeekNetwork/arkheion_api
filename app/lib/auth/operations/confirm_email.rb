# frozen_string_literal: true

module Auth
  module Operations
    class ConfirmEmail < BaseOperation
      def call(token:)
        user = User.confirm_by_token(token)

        if user.errors.any?
          Failure[:invalid_token, user.errors.full_messages.first]
        else
          tokens = step generate_tokens(user)
          Success(user: user, tokens: tokens)
        end
      end

      private

      def generate_tokens(user)
        Success(
          access_token: JwtService.encode_access_token(user),
          refresh_token: JwtService.encode_refresh_token(user)
        )
      end
    end
  end
end
