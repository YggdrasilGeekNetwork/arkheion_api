# frozen_string_literal: true

require_relative "pipe_test_case"

class ComputeResourcesTest < ActiveSupport::TestCase
  include PipeTestCase

  def run_resources(sheet:, level_ups: [], state: nil)
    ctx = build_context(sheet: sheet, level_ups: level_ups, state: state)
    with_base_attributes(ctx)
    Tormenta20::Pipeline::Pipes::ComputeResources.call(ctx)
    ctx
  end

  # Guerreiro: initial_hp=20, hp_per_level=5, mp_per_level=3
  test "guerreiro level 1 PV = initial_hp + CON mod" do
    s   = sheet(sheet_attributes: { "constituicao" => 14 })
    lu  = level_up(class_key: "guerreiro", level: 1)
    ctx = run_resources(sheet: s, level_ups: [lu])

    assert_equal 22, ctx[:computed_resources][:pv][:max]  # 20 + 2 (con mod)
  end

  test "guerreiro level 2 PV adds hp_per_level + CON mod" do
    s   = sheet(sheet_attributes: { "constituicao" => 14 })
    lu1 = level_up(class_key: "guerreiro", level: 1)
    lu2 = level_up(class_key: "guerreiro", level: 2)
    ctx = run_resources(sheet: s, level_ups: [lu1, lu2])

    assert_equal 29, ctx[:computed_resources][:pv][:max]  # (20+2) + (5+2)
  end

  test "guerreiro PM = 3 per level" do
    lu1 = level_up(class_key: "guerreiro", level: 1)
    lu2 = level_up(class_key: "guerreiro", level: 2)
    ctx = run_resources(sheet: sheet, level_ups: [lu1, lu2])

    assert_equal 6, ctx[:computed_resources][:pm][:max]
  end

  test "PV is at least 1" do
    s   = sheet(sheet_attributes: { "constituicao" => 1 })  # con mod = -5
    lu  = level_up(class_key: "arcanista", level: 1)        # initial_hp low
    ctx = run_resources(sheet: s, level_ups: [lu])

    assert ctx[:computed_resources][:pv][:max] >= 1
  end

  test "movement comes from race base (humano = 9m by default)" do
    ctx = run_resources(sheet: sheet)

    deslocamento = ctx[:computed_resources][:deslocamento]
    assert deslocamento[:total] >= 3  # at least minimum
  end

  test "other_bonuses arrays start empty" do
    lu  = level_up(class_key: "guerreiro", level: 1)
    ctx = run_resources(sheet: sheet, level_ups: [lu])

    assert_empty ctx[:computed_resources][:pv][:other_bonuses]
    assert_empty ctx[:computed_resources][:pm][:other_bonuses]
  end
end
