# frozen_string_literal: true

module Tormenta20
  module Pipeline
    class Context
      attr_reader :character_sheet, :level_ups, :state, :data, :errors

      def initialize(character_sheet:, level_ups: nil, state: nil, data: {})
        @character_sheet = character_sheet
        @level_ups = level_ups || character_sheet.level_ups.order(:level).to_a
        @state = state || character_sheet.character_state
        @data = data.with_indifferent_access
        @errors = []
      end

      def success?
        @errors.empty?
      end

      def failure?
        !success?
      end

      def add_error(message, source: nil)
        @errors << { message: message, source: source }
        self
      end

      def merge(new_data)
        @data.merge!(new_data)
        self
      end

      def [](key)
        @data[key]
      end

      def []=(key, value)
        @data[key] = value
      end

      def fetch(key, default = nil)
        @data.fetch(key, default)
      end

      def to_h
        @data.to_h
      end

      def dup_with(new_data)
        self.class.new(
          character_sheet: character_sheet,
          level_ups: level_ups,
          state: state,
          data: @data.merge(new_data)
        )
      end
    end
  end
end
