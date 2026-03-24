# frozen_string_literal: true

module Mutations
  module Tormenta20
    class BaseMutation < GraphQL::Schema::Mutation
      private

      def current_user
        context[:current_user]
      end

      def require_authentication!
        raise GraphQL::ExecutionError, "Not authenticated" unless current_user
      end

      def handle_result(result)
        case result
        in Dry::Monads::Success(payload)
          payload
        in Dry::Monads::Failure[:not_found, message]
          raise GraphQL::ExecutionError, message
        in Dry::Monads::Failure[:validation_error, errors]
          raise GraphQL::ExecutionError, format_errors(errors)
        in Dry::Monads::Failure[:persistence_error, errors]
          raise GraphQL::ExecutionError, format_errors(errors)
        in Dry::Monads::Failure[error_type, message]
          raise GraphQL::ExecutionError, message.to_s
        end
      end

      def format_errors(errors)
        case errors
        when Hash
          errors.map { |field, messages| "#{field}: #{Array(messages).join(', ')}" }.join("; ")
        when Array
          errors.join("; ")
        else
          errors.to_s
        end
      end

      def find_character_sheet!(id)
        sheet = ::Tormenta20::CharacterSheet.find_by(id: id, user_id: current_user.id)
        raise GraphQL::ExecutionError, "Character sheet not found" unless sheet

        sheet
      end
    end
  end
end
