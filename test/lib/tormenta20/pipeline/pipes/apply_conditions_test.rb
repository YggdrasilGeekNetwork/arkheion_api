# frozen_string_literal: true

require_relative "pipe_test_case"

class ApplyConditionsTest < ActiveSupport::TestCase
  include PipeTestCase

  def run_with_conditions(conditions)
    st  = state(active_conditions: conditions)
    s   = sheet(sheet_attributes: { "destreza" => 2 })
    ctx = build_context(sheet: s, state: st)
    with_base_attributes(ctx)
    Tormenta20::Pipeline::Pipes::ComputeDefenses.call(ctx)
    Tormenta20::Pipeline::Pipes::ComputeCombat.call(ctx)
    Tormenta20::Pipeline::Pipes::ApplyConditions.call(ctx)
    ctx
  end

  test "no conditions leaves totals unchanged" do
    ctx = run_with_conditions([])

    defesa_total = ctx[:computed_defenses][:defesa][:total]
    assert_equal 12, defesa_total  # 10 + 2 dex
  end

  test "caido applies -4 penalty to melee attack" do
    ctx = run_with_conditions([{ "condition_key" => "caido", "stacks" => 1 }])

    penalty = ctx[:computed_combat][:melee_attack][:condition_penalty]
    total   = ctx[:computed_combat][:melee_attack][:total]

    assert_equal(-4, penalty)
    assert_equal(-4, total)  # 0 BAB + 0 STR - 4 penalty
  end

  test "abalado applies -2 to all skill totals" do
    s   = sheet(sheet_attributes: { "destreza" => 2 })
    st  = state(active_conditions: [{ "condition_key" => "abalado", "stacks" => 1 }])
    ctx = build_context(sheet: s, state: st)
    with_base_attributes(ctx)
    Tormenta20::Pipeline::Pipes::ComputeSkills.call(ctx)
    Tormenta20::Pipeline::Pipes::ComputeDefenses.call(ctx)
    Tormenta20::Pipeline::Pipes::ComputeCombat.call(ctx)
    Tormenta20::Pipeline::Pipes::ApplyConditions.call(ctx)

    assert_equal(-2, ctx[:computed_skills]["acrobacia"][:condition_penalty])
    assert_equal 0, ctx[:computed_skills]["acrobacia"][:total]  # 2 dex - 2 penalty
  end

  test "cego applies -4 to attack and -2 to defense" do
    ctx = run_with_conditions([{ "condition_key" => "cego", "stacks" => 1 }])

    assert_equal(-4, ctx[:computed_combat][:melee_attack][:condition_penalty])
    assert_equal(-2, ctx[:computed_defenses][:defesa][:condition_penalty])
  end

  test "stacks multiplies the penalty" do
    ctx = run_with_conditions([{ "condition_key" => "lento", "stacks" => 2 }])

    # lento: attack -1 per stack
    assert_equal(-2, ctx[:computed_combat][:melee_attack][:condition_penalty])
  end

  test "active_condition_effects are stored in context" do
    ctx = run_with_conditions([{ "condition_key" => "enjoado", "stacks" => 1 }])

    conditions = ctx[:active_condition_effects]
    assert_equal 1, conditions.size
    assert_equal "enjoado", conditions.first[:condition_key]
  end
end
