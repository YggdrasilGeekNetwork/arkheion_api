# frozen_string_literal: true

module Tormenta20
  module Operations
    module Snapshots
      class ComputeLive < BaseOperation
        def call(character_sheet:)
          context = Pipeline::SnapshotPipeline.call(character_sheet, include_state: true)

          if context.success?
            Success(
              computed_data: context.to_h,
              character_sheet: character_sheet,
              state: character_sheet.character_state
            )
          else
            Failure[:computation_error, context.errors]
          end
        end
      end
    end
  end
end
