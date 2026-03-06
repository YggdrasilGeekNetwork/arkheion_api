# frozen_string_literal: true

module Tormenta20
  module Interactions
    module Snapshots
      class ComputeLive < BaseInteraction
        def call(character_sheet:)
          context = Pipeline::SnapshotPipeline.call(character_sheet, include_state: true)

          if context.success?
            Success(
              computed_data: context.to_h,
              character_sheet: character_sheet,
              state: character_sheet.character_state
            )
          else
            Failure(errors: context.errors)
          end
        end
      end
    end
  end
end
