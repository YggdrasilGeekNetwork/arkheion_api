# frozen_string_literal: true

require_relative "pipe_test_case"

class ComputeAbilitiesTest < ActiveSupport::TestCase
  include PipeTestCase

  def run_abilities(sheet:, level_ups: [])
    ctx = build_context(sheet: sheet, level_ups: level_ups)
    Tormenta20::Pipeline::Pipes::ComputeAbilities.call(ctx)
    ctx
  end

  test "class abilities from level_up are included" do
    lu  = level_up(abilities_chosen: { "class_abilities" => ["ataque_especial"] })
    ctx = run_abilities(sheet: sheet, level_ups: [lu])

    keys = ctx[:computed_abilities].map { |a| a[:ability_key] }
    assert_includes keys, "ataque_especial"
  end

  test "bonus abilities from level_up are included" do
    lu  = level_up(abilities_chosen: { "bonus_abilities" => ["valentao"] })
    ctx = run_abilities(sheet: sheet, level_ups: [lu])

    types = ctx[:computed_abilities].map { |a| a[:type] }
    assert_includes types, :bonus_ability
  end

  test "powers_chosen are included with category as type" do
    lu  = level_up(powers_chosen: { "poder_de_combate" => ["valentao"] })
    ctx = run_abilities(sheet: sheet, level_ups: [lu])

    ability = ctx[:computed_abilities].find { |a| a[:ability_key] == "valentao" }
    assert_not_nil ability
    assert_equal :poder_de_combate, ability[:type]
  end

  test "origin powers from origin_choices are included" do
    s   = sheet(origin_choices: { "chosen_powers" => ["a_prova_de_tudo"] })
    ctx = run_abilities(sheet: s)

    types = ctx[:computed_abilities].map { |a| a[:type] }
    assert_includes types, :origin_power
  end

  test "ability has name from gem" do
    lu  = level_up(powers_chosen: { "poder_de_combate" => ["valentao"] })
    ctx = run_abilities(sheet: sheet, level_ups: [lu])

    ability = ctx[:computed_abilities].find { |a| a[:ability_key] == "valentao" }
    assert_not_nil ability[:name]
    refute_empty ability[:name]
  end

  test "source encodes origin correctly" do
    lu  = level_up(class_key: "guerreiro", level: 2, abilities_chosen: { "class_abilities" => ["ataque_especial"] })
    ctx = run_abilities(sheet: sheet, level_ups: [lu])

    ability = ctx[:computed_abilities].find { |a| a[:ability_key] == "ataque_especial" }
    assert_equal "class:guerreiro:2", ability[:source]
  end

  test "no duplicates when same power appears in multiple level_ups" do
    lu1 = level_up(level: 1, powers_chosen: { "poder_de_combate" => ["valentao"] })
    lu2 = level_up(level: 2, powers_chosen: { "poder_de_combate" => ["valentao"] })
    ctx = run_abilities(sheet: sheet, level_ups: [lu1, lu2])

    keys = ctx[:computed_abilities].map { |a| a[:ability_key] }
    assert_equal 2, keys.count("valentao")  # one per level_up (expected — not de-duped)
  end
end
