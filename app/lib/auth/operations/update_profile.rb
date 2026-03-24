# frozen_string_literal: true

module Auth
  module Operations
    class UpdateProfile < BaseOperation
      def call(user:, username: nil, display_name: nil)
        attrs = {}
        attrs[:username]     = username     if username.present?
        attrs[:display_name] = display_name unless display_name.nil?

        if attrs.empty? || user.update(attrs)
          Success(user: user)
        else
          Failure[:validation_error, user.errors.to_h]
        end
      end
    end
  end
end
