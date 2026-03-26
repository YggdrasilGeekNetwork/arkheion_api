# frozen_string_literal: true

module Tormenta20
  module Operations
    module Characters
      class Create < BaseOperation
        def call(params:, user:)
          step validate_gem_references(params)

          step_failure = nil
          presenter    = nil

          ActiveRecord::Base.transaction do
            failure = catch(:halt) do
              sheet = step build_sheet(params, user)
              sheet = step persist(sheet)
              step build_first_level_up(sheet, params)
              step generate_snapshot(sheet)

              snapshot = sheet.reload.latest_snapshot
              step check_snapshot(snapshot)

              state = step initialize_state(sheet, snapshot, params)
              sheet.increment!(:character_version)

              presenter = Presenters::CharacterPresenter.new(
                sheet.reload,
                state: state.reload,
                snapshot: snapshot
              )
              nil
            end

            if failure
              step_failure = failure
              raise ActiveRecord::Rollback
            end
          end

          throw :halt, step_failure if step_failure

          Success(character: presenter)
        end

        private

        def validate_gem_references(params)
          race_key   = params[:race_key]
          origin_key = params[:origin_key]
          class_key  = params.dig(:first_level, :class_key)

          errors = {}

          errors[:race_key]   = ["'#{race_key}' not found in gem"]   unless ::Tormenta20::Models::Raca.find_by(id: race_key)
          errors[:origin_key] = ["'#{origin_key}' not found in gem"] unless ::Tormenta20::Models::Origem.find_by(id: origin_key)
          errors[:class_key]  = ["'#{class_key}' not found in gem"]  unless ::Tormenta20::Models::Classe.find_by(id: class_key)

          if params[:deity_key].present?
            errors[:deity_key] = ["'#{params[:deity_key]}' not found in gem"] unless ::Tormenta20::Models::Divindade.find_by(id: params[:deity_key])
          end

          errors.empty? ? Success(true) : Failure[:validation_error, errors]
        end

        def build_sheet(params, user)
          sheet = CharacterSheet.new(
            user:             user,
            name:             params[:name],
            image_url:        params[:image_url],
            race_key:         params[:race_key],
            origin_key:       params[:origin_key],
            deity_key:        params[:deity_key],
            sheet_attributes: params[:sheet_attributes] || {},
            race_choices:     params[:race_choices] || {},
            origin_choices:   params[:origin_choices] || {},
            proficiencies:    {}
          )
          Success(sheet)
        end

        def build_first_level_up(sheet, params)
          first_level = (params[:first_level] || {}).merge(level: 1)
          LevelUps::Create.new.call(character_sheet: sheet, params: first_level)
        end

        def generate_snapshot(sheet)
          result = Operations::Snapshots::Generate.new.call(character_sheet: sheet.reload, force: true)
          result.failure? ? Failure[:snapshot_error, result.failure] : Success(true)
        end

        def check_snapshot(snapshot)
          snapshot ? Success(snapshot) : Failure[:snapshot_error, "Snapshot not persisted"]
        end

        def initialize_state(sheet, snapshot, params)
          inventory = (params[:starting_inventory] || []).map do |item|
            { "item_id" => item[:item_id], "item_key" => item[:item_key], "quantity" => item[:quantity] }
          end

          currency_input = params[:starting_currency] || {}
          currency = {
            "tc" => (currency_input[:tc] || 0),
            "tp" => (currency_input[:tp] || 0),
            "to" => (currency_input[:to] || 0)
          }

          state = sheet.character_state
          state.update!(
            current_pv:             snapshot.pv_max,
            current_pm:             snapshot.pm_max,
            available_actions_data: { "standard" => 1, "movement" => 1, "free" => 1, "full" => 1, "reaction" => 1 },
            inventory:              inventory,
            currency:               currency
          )
          Success(state)
        end
      end
    end
  end
end
