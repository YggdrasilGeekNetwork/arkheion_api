# frozen_string_literal: true

module Tormenta20
  module Operations
    module Characters
      class LevelUp < BaseOperation
        def call(id:, params:, user:)
          sheet = step find_character_sheet(id, user: user)
          step apply_level_up(sheet, params)
          Success(character: Presenters::CharacterPresenter.new(sheet.reload))
        end

        private

        def apply_level_up(sheet, params)
          updates = {
            classes_data: serialize_array(params[:classes]),
            max_pv: params[:max_health],
            max_pm: params[:max_mana]
          }
          updates[:attributes_data] = serialize_array(params[:attributes]) if params[:attributes].present?
          updates[:skills_data]     = serialize_array(params[:skills])     if params[:skills].present?

          sheet.assign_attributes(updates)
          sheet.character_version += 1

          if sheet.save
            # Also update current resources to new max on level up
            state = sheet.character_state
            if state
              state.update(current_pv: params[:max_health].to_i, current_pm: params[:max_mana].to_i)
            end
            Success(sheet)
          else
            Failure[:persistence_error, sheet.errors.to_h]
          end
        end

        def serialize_array(value)
          return [] if value.blank?

          value.map { |item| item.respond_to?(:to_h) ? item.to_h : item }
        end
      end
    end
  end
end
