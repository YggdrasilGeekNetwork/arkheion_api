# frozen_string_literal: true

module Auth
  class JwtService
    ALGORITHM = 'HS256'
    ACCESS_TOKEN_EXPIRY = Rails.env.development? ? 1.year : 15.minutes
    REFRESH_TOKEN_EXPIRY = Rails.env.development? ? 1.year : 7.days

    class << self
      def encode_access_token(user)
        payload = {
          sub: user.id,
          jti: user.jti,
          type: 'access',
          exp: ACCESS_TOKEN_EXPIRY.from_now.to_i,
          iat: Time.current.to_i
        }

        JWT.encode(payload, secret_key, ALGORITHM)
      end

      def encode_refresh_token(user)
        payload = {
          sub: user.id,
          jti: user.jti,
          type: 'refresh',
          exp: REFRESH_TOKEN_EXPIRY.from_now.to_i,
          iat: Time.current.to_i
        }

        JWT.encode(payload, secret_key, ALGORITHM)
      end

      def decode(token)
        decoded = JWT.decode(token, secret_key, true, { algorithm: ALGORITHM })
        HashWithIndifferentAccess.new(decoded.first)
      rescue JWT::ExpiredSignature
        nil
      rescue JWT::DecodeError
        nil
      end

      def valid_access_token?(token)
        payload = decode(token)
        return false unless payload
        return false unless payload[:type] == 'access'

        user = User.find_by(id: payload[:sub])
        return false unless user
        return false unless user.jti == payload[:jti]
        return false unless user.active?

        user
      end

      def valid_refresh_token?(token)
        payload = decode(token)
        return false unless payload
        return false unless payload[:type] == 'refresh'

        user = User.find_by(id: payload[:sub])
        return false unless user
        return false unless user.jti == payload[:jti]
        return false unless user.active?

        user
      end

      private

      def secret_key
        Rails.application.credentials.secret_key_base || ENV.fetch('SECRET_KEY_BASE')
      end
    end
  end
end
