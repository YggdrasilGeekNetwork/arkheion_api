# frozen_string_literal: true

module Auth
  module Operations
    class OauthGoogle < BaseOperation
      def call(id_token:)
        payload = step verify_google_token(id_token)
        user = step find_or_create_user(payload)
        tokens = step generate_tokens(user)
        Success(user: user, tokens: tokens)
      end

      private

      def verify_google_token(id_token)
        payload = Auth::GoogleTokenVerifier.verify!(id_token)
        Success(payload)
      rescue Auth::GoogleTokenError => e
        Failure[:invalid_token, e.message]
      end

      def find_or_create_user(payload)
        email      = payload["email"]
        uid        = payload["sub"]
        name       = payload["name"]
        avatar_url = payload["picture"]

        # Find existing OAuth identity
        identity = OauthIdentity.find_by(provider: "google", uid: uid)
        if identity
          identity.update!(email: email, name: name, avatar_url: avatar_url)
          return Success(identity.user)
        end

        # Find user by email — link Google to existing account
        user = User.find_by(email: email.downcase)
        if user
          OauthIdentity.create!(
            user: user, provider: "google", uid: uid,
            email: email, name: name, avatar_url: avatar_url
          )
          user.confirm! unless user.confirmed?
          return Success(user)
        end

        # Create brand-new user
        user = User.new(
          email: email.downcase,
          username: generate_username(email),
          display_name: name,
          avatar_url: avatar_url,
          confirmed_at: Time.current # Google already verified the email
        )

        if user.save(validate: false)
          OauthIdentity.create!(
            user: user, provider: "google", uid: uid,
            email: email, name: name, avatar_url: avatar_url
          )
          Success(user)
        else
          Failure[:validation_error, user.errors.to_h]
        end
      end

      def generate_username(email)
        base      = email.split("@").first.gsub(/[^a-z0-9]/i, "_").downcase.first(28)
        candidate = base
        n         = 1
        while User.exists?(username: candidate)
          candidate = "#{base}_#{n}"
          n += 1
        end
        candidate
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
