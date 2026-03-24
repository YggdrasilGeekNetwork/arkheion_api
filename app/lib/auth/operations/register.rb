# frozen_string_literal: true

module Auth
  module Operations
    class Register < BaseOperation
      def call(email:, username:, password:, password_confirmation:)
        step validate_passwords(password, password_confirmation)
        guest = step check_guest_list(email)
        user = step create_user(email, username, password)
        guest&.mark_as_used!
        tokens = step generate_tokens(user)

        Success(user: user, tokens: tokens)
      end

      private

      def check_guest_list(email)
        guest = Guest.find_by(email: email.downcase.strip)
        return Failure[:not_invited, "Este email não está na lista de convidados"] if guest.nil?
        return Failure[:already_registered, "Este convidado já registrou uma conta"] if guest.used?

        Success(guest)
      end

      def validate_passwords(password, password_confirmation)
        if password == password_confirmation
          Success(true)
        else
          Failure[:validation_error, { password_confirmation: ["does not match password"] }]
        end
      end

      def create_user(email, username, password)
        user = User.new(
          email: email,
          username: username,
          password: password
        )

        if user.save
          user.send_confirmation_instructions
          Success(user)
        else
          Failure[:validation_error, user.errors.to_h]
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
