# frozen_string_literal: true

require_relative "../../../../unit_test_helper"

# Base class for pipeline pipe unit tests.
# Builds lightweight in-memory doubles so no PostgreSQL access is needed.
module PipeTestCase
  FakeSheet = Struct.new(
    :race_key, :origin_key, :deity_key,
    :sheet_attributes, :race_choices, :origin_choices, :proficiencies,
    :character_state,
    keyword_init: true
  )

  FakeLevelUp = Struct.new(
    :class_key, :level,
    :abilities_chosen, :powers_chosen, :skill_points,
    :spells_chosen, :class_choices, :metadata,
    keyword_init: true
  )

  FakeState = Struct.new(
    :equipped_items, :active_conditions, :active_effects,
    :inventory, :currency,
    keyword_init: true
  )

  def sheet(attrs = {})
    FakeSheet.new({
      race_key: "humano",
      origin_key: "acolito",
      deity_key: nil,
      sheet_attributes: { "forca" => 10, "destreza" => 10, "constituicao" => 10,
                          "inteligencia" => 10, "sabedoria" => 10, "carisma" => 10 },
      race_choices: {},
      origin_choices: {},
      proficiencies: {},
      character_state: nil
    }.merge(attrs))
  end

  def level_up(attrs = {})
    FakeLevelUp.new({
      class_key: "guerreiro", level: 1,
      abilities_chosen: {}, powers_chosen: {}, skill_points: {},
      spells_chosen: {}, class_choices: {}, metadata: {}
    }.merge(attrs))
  end

  def state(attrs = {})
    FakeState.new({
      equipped_items: {}, active_conditions: [], active_effects: [],
      inventory: [], currency: {}
    }.merge(attrs))
  end

  def build_context(sheet:, level_ups: [], state: nil, data: {})
    Tormenta20::Pipeline::Context.new(
      character_sheet: sheet,
      level_ups: level_ups,
      state: state,
      data: data
    )
  end

  # Run ComputeBaseAttributes so later pipes have computed_attributes available.
  def with_base_attributes(context)
    Tormenta20::Pipeline::Pipes::ComputeBaseAttributes.call(context)
  end
end
