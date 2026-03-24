# frozen_string_literal: true

module Auth
  class GoogleTokenVerifier
    def self.verify!(id_token)
      validator = GoogleIDToken::Validator.new
      payload = validator.check(id_token, ENV.fetch("GOOGLE_CLIENT_ID"))
      raise GoogleTokenError, "Invalid Google token" unless payload
      payload
    rescue GoogleIDToken::ValidationError => e
      raise GoogleTokenError, e.message
    end
  end

  class GoogleTokenError < StandardError; end
end
