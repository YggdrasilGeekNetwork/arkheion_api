# frozen_string_literal: true

module Tormenta20
  module Interactions
    class BaseInteraction
      include Dry::Monads[:result, :do]

      class << self
        def call(...)
          new.call(...)
        end

        def to_proc
          ->(args) { call(args) }
        end
      end

      private

      def validate(contract_class, params)
        result = contract_class.new.call(params)

        if result.success?
          Success(result.to_h)
        else
          Failure(errors: result.errors.to_h)
        end
      end

      def find_character_sheet(id, user:)
        sheet = CharacterSheet.find_by(id: id, user_id: user.id)

        if sheet
          Success(sheet)
        else
          Failure(error: :not_found, message: "Character sheet not found")
        end
      end

      def transaction(&block)
        result = nil
        ActiveRecord::Base.transaction do
          result = block.call
          raise ActiveRecord::Rollback if result.failure?
        end
        result
      end
    end
  end
end
