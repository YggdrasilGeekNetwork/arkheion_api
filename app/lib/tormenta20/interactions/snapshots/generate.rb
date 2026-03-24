# frozen_string_literal: true

module Tormenta20
  module Interactions
    module Snapshots
      class Generate < BaseInteraction
        def call(character_sheet:, force: false)
          return cached_snapshot(character_sheet) unless force || character_sheet.snapshot_stale?

          context = yield compute_snapshot(character_sheet)
          snapshot = yield persist_snapshot(character_sheet, context)

          Success(snapshot: snapshot, context: context)
        end

        private

        def cached_snapshot(sheet)
          snapshot = sheet.latest_snapshot
          return Failure(error: :not_found, message: "No snapshot available") unless snapshot

          Success(snapshot: snapshot, cached: true)
        end

        def compute_snapshot(sheet)
          context = Pipeline::SnapshotPipeline.call(sheet, include_state: false)

          if context.success?
            Success(context)
          else
            Failure(errors: context.errors)
          end
        end

        def persist_snapshot(sheet, context)
          snapshot = sheet.snapshots.new(
            checksum: sheet.compute_checksum,
            computed_attributes: context[:computed_attributes],
            computed_defenses: context[:computed_defenses],
            computed_skills: context[:computed_skills],
            computed_combat: context[:computed_combat],
            computed_resources: context[:computed_resources],
            computed_abilities: context[:computed_abilities],
            computed_spells: context[:computed_spells],
            computed_proficiencies: context[:computed_proficiencies],
            full_snapshot: context.to_h
          )

          if snapshot.save
            Success(snapshot)
          else
            Failure(errors: snapshot.errors.to_h)
          end
        end
      end
    end
  end
end
