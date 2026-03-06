# frozen_string_literal: true

module Tormenta20
  module Pipeline
    class Runner
      attr_reader :pipes

      def initialize(*pipes)
        @pipes = pipes.flatten
      end

      def call(context)
        pipes.reduce(context) do |ctx, pipe|
          break ctx if ctx.failure?

          result = pipe.call(ctx)
          result.is_a?(Context) ? result : ctx
        end
      end

      def >>(other)
        Runner.new(pipes + Array(other.respond_to?(:pipes) ? other.pipes : other))
      end

      def self.compose(*pipes)
        new(pipes)
      end
    end
  end
end
