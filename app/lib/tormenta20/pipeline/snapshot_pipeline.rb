# frozen_string_literal: true

module Tormenta20
  module Pipeline
    class SnapshotPipeline
      PIPES = [
        Pipes::ComputeBaseAttributes,
        Pipes::ComputeSkills,
        Pipes::ComputeDefenses,
        Pipes::ComputeCombat,
        Pipes::ComputeAbilities,
        Pipes::ComputeSpells,
        Pipes::ComputeProficiencies,
        Pipes::ComputeSenses,
        Pipes::ApplyEquipmentModifiers,
        Pipes::ApplyConditions,
        Pipes::ApplyActiveEffects,
        Pipes::ComputeResources,
        Pipes::ApplyEncumbrance
      ].freeze

      def self.call(character_sheet, include_state: true)
        new(character_sheet, include_state: include_state).call
      end

      def initialize(character_sheet, include_state: true)
        @character_sheet = character_sheet
        @include_state = include_state
      end

      def call
        context = Context.new(
          character_sheet: @character_sheet,
          state: @include_state ? @character_sheet.character_state : nil
        )

        runner = Runner.new(pipes_to_run)
        runner.call(context)
      end

      private

      def pipes_to_run
        if @include_state
          PIPES
        else
          # Skip state-dependent pipes when computing pure snapshot
          PIPES - [
            Pipes::ApplyEquipmentModifiers,
            Pipes::ApplyConditions,
            Pipes::ApplyActiveEffects,
            Pipes::ApplyEncumbrance
          ]
        end
      end
    end
  end
end
