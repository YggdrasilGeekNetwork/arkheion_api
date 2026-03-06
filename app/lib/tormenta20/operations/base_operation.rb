# frozen_string_literal: true

module Tormenta20
  module Operations
    class BaseOperation < Dry::Operation
      include Dry::Monads[:result]

      private

      def validate(contract_class, params)
        result = contract_class.new.call(params)

        if result.success?
          Success(result.to_h)
        else
          Failure[:validation_error, result.errors.to_h]
        end
      end

      def find_character_sheet(id, user:)
        sheet = CharacterSheet.find_by(id: id, user_id: user.id)

        if sheet
          Success(sheet)
        else
          Failure[:not_found, 'Character sheet not found']
        end
      end

      def persist(record)
        if record.save
          Success(record)
        else
          Failure[:persistence_error, record.errors.to_hash]
        end
      end

      def authorize!(user:, resource:, action:)
        # Policy check placeholder - integrate with Pundit or similar
        Success(true)
      end
    end
  end
end
